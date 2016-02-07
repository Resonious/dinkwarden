require 'cgi'
require 'active_support'
require 'active_support/core_ext'
require 'discordrb'
require_relative 'matchers_and_messages.rb'

class Config
  class << self
    attr_accessor :email
    attr_accessor :password
    attr_accessor :admins
  end
end
require_relative 'config.rb'

if Config.email.blank? || Config.password.blank?
  puts "Please set Config.email and Config.password in 'config.rb'"
  exit
end

bot = Discordrb::Bot.new(Config.email, Config.password)
admins = Config.admins

@admin_instances = {}
@server  = nil
@jail    = nil
@targets = []
@channel_id = nil
@leave_attempts = {}
@quiet = false
@asking_about_quiet = {}
@responded_to_love = false
@time_last_taunted = Time.now

def initialize_warden(event)
  @server = event.server

  if @server.nil?
    event.respond "#{event.author.mention} I COULD NOT FIND YOUR SERVER. SORRY SIR"
    return
  end

  @channel_id = event.channel.id
  @jail       = bot.find('jail', @server.name).first

  unless bot.bot_user.can_move_members?(@server)
    event.respond "#{event.author.mention} I DO NOT HAVE PERMISSION TO MONITOR THE JAIL"
    return
  end

  @admin_instances[event.author.name] = event.author

  event.respond affirmative

  if @jail.nil?
    event.respond could_not_find_jail
  end
end

bot.message(from: admins) do |event|
  case event.message 
  when warden?
    initialize_warden(event)

  when jail?
    @server = event.server
    event.message.mentions.each do |partial_user|
      @targets << partial_user
      @server.move(partial_user, @jail)
    end
  end
end

def admin_command(bot, private)
  lambda do |event|
    case event.message
    when release?
      if private
        user_names_to_release = event.message.text.split(/\s+/)
          .select { |name| name =~ /^@\S+/ }
          .map { |name| name.gsub(/^@/, '').gsub(/,/, '') }

        if user_names_to_release.empty?
          event.respond "RELEASE WHO? SPECIFY USERS TO RELEASE WITH @USERNAME"
        end

        user_names_to_release.each do |user_name|
          released = nil
          @targets.delete_if { |t| (t.name.downcase == user_name.downcase && released = t) }

          if released.nil?
            event.respond "COULD NOT FIND #{user_name}"
          else
            event.respond "DONE. THEY MAY LEAVE"
            bot.send_message @channel_id, you_are_free(released)

            if @leave_attempts[released.id] && @leave_attempts[released.id] >= 10
              released.pm "I'LL SEE YOU AGAIN, I'M SURE"
            end
          end
        end

      else
        if event.message.mentions.empty?
          event.respond "#{event.author.mention} RELEASE WHO? @MENTION THEM TO ME"
        end

        event.message.mentions.each do |user|
          next if user.id == bot.bot_user.id

          if @targets.delete_if { |t| t.id == user.id }.empty?
            event.respond you_are_already_free(user)
          else
            event.respond you_are_free(user)

            if @leave_attempts[user.id] && @leave_attempts[user.id] >= 10
              user.pm "YOU ARE FREE NOW. I EXPECT TO SEE YOU AGAIN"
            end
          end
        end
      end

    when criminals?
      if @targets.empty?
        event.respond no_criminals
      else
        event.respond "#{@targets.size} CRIMINAL#{'S' if @targets.size != 1} IMPRISONED"
      end

    when quiet?
      if @asking_about_quiet[event.author.id]
        case event.message.text.downcase.chomp
        when /yes/
          event.respond "OKAY. TELL ME TO SPEAK UP WHEN YOU CHANGE YOUR MIND"
          @quiet = true
          @asking_about_quiet[event.author.id] = false
        when /no/
          event.respond "UNDERSTOOD"
          @quiet = false
          @asking_about_quiet[event.author.id] = false
        else
          event.respond "WHAT WAS THAT???"
        end

      else
        event.respond "FROM NOW ON, I WILL NOT REPORT EVERY SINGLE ESCAPE ATTEMPT"
        event.respond "#{event.author.mention} IS THAT OKAY?"
        @asking_about_quiet[event.author.id] = true
      end

    when speak?
      event.respond "GOT IT"
      @quiet = false

    when compliment?
      event.respond thank_you

    when love?
      if !@responded_to_love || Random.rand(3) == 1
        event.respond uhhhhh
        @responded_to_love = true
      end
    end
  end
end

def peasant_command(bot, mention)
  lambda do |event|
    msg = ""
    msg += "#{event.author.mention} " if mention
    msg += %w(FOOLISH FOOL ... PEASANT).sample
    event.respond msg
  end
end

bot.mention({ from: admins }, &admin_command(bot, false))
bot.message({ from: admins, private: true }, &admin_command(bot, true))

bot.mention({ from: not!(admins) }, &peasant_command(bot, true))
bot.message({ from: not!(admins), private: true }, &peasant_command(bot, false))

bot.voice_state_update(from: not!('DinkWarden'), channel: 'jail') do |event|
  next if @server.nil? || @jail.nil?
  next unless @server.id == event.server.id
  next unless event.channel.type == 'voice'

  next if @targets.map(&:id).include? event.user.id

  @targets << event.user
  bot.send_message @channel_id, "CRIMINAL! #{event.user.mention}"
  if @leave_attempts[event.user.id] && @leave_attempts[event.user.id] >= 5
    event.user.pm "NOT YOU AGAIN"
  end
end

bot.voice_state_update(from: not!('DinkWarden'), channel: not!('jail')) do |event|
  puts "#{event.user.name} joined #{event.channel.name}"

  next if @server.nil? || @jail.nil?
  next unless @server.id == event.server.id
  next unless event.channel.type == 'voice'
  next unless @targets.map(&:id).include? event.user.id

  @leave_attempts[event.user.id] ||= 0
  @leave_attempts[event.user.id] += 1

  @server.move(event.user, @jail)
  if !@quiet && Time.now >= @time_last_taunted + 2.seconds
    bot.send_message @channel_id, taunt_for_trying_to_leave(event.user)
    @time_last_taunted = Time.now
  end

  if @leave_attempts[event.user.id] > 100
    event.user.pm "STOP"

    if @leave_attempts[event.user.id] == 101
      @admin_instances.each do |id, admin|
        admin.pm "#{event.user.mention} HAS ATTEMPTED TO ESCAPE OVER 100 TIMES..."
      end
    end

  elsif @leave_attempts[event.user.id] == 50
    event.user.pm "YOU'RE REALLY GETTING ON MY NERVES"

  elsif @leave_attempts[event.user.id] == 25
    event.user.pm "IT WAS TOO POLITE OF ME TO CALL YOU A PEASANT"
    sleep 1
    event.user.pm "ACCEPT YOUR FATE!"

  elsif @leave_attempts[event.user.id] == 10
    event.user.pm "KNOW YOUR PLACE, PEASANT"
  end
end

bot.ready { puts "WARDEN READY" }

bot.run
