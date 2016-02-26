def warden?
  proc do |message|
    message.text.downcase == "warden!"
  end
end

def affirmative
  [
    "YES SIR", "HERE", "YES", "PRESENT", "AFFIRMATIVE", "OK"
  ]
    .sample
end

def jail?
  proc do |message|
    !message.mentions.empty? && (
      (message.text.downcase =~ /jail/)    ||
      (message.text.downcase =~ /turn in/) ||
      (message.text.downcase =~ /lock\s+.+up/)
    )
  end
end

def could_not_find_jail
  [
    "I COULD NOT FIND A JAIL IN THIS SERVER",
    "IS THERE A JAIL IN THIS SERVER?",
    "I'M GONNA NEED A CHANNEL CALLED 'jail'.",
    "LET ME KNOW WHEN THERE IS A JAIL CHANNEL"
  ]
    .sample
end

def taunt_for_trying_to_leave(user)
  [
    "#{user.mention} DID YOU REALLY THINK IT WOULD BE SO EASY?",
    "#{user.mention} THOUGHT YOU COULD ESCAPE, HUH",
    "#{user.mention}! GOT YOU!",
    "#{user.mention} FOOLISH",
    "COME ON, #{user.mention}",
    "STOP TRYING #{user.mention}",
    "#{user.mention} STAY PUT",
    "#{user.mention} YOU CANNOT ESCAPE",
    "#{user.mention}! PLEASE.",
    "#{user.mention} HOW DARE YOU",
    "DON'T THINK YOU CAN JUST LEAVE #{user.mention}",
    "TRY HARDER NEXT TIME, #{user.mention}",
    "GIVE UP! #{user.mention}",
    "#{user.mention} YOU FOOL!!!",
    "#{user.mention} YOU ARE IN JAIL",
    "#{user.mention} YOU THINK YOU CAN ESCAPE FROM JAIL?",
    "#{user.mention} ATTEMPTED TO ESCAPE. HAH!",
    "#{user.mention} FEEBIL",
    "#{user.mention} YOU'RE FREE! JUST KIDDING.",
    "#{user.mention} YOU CANNOT LEAVE THE JAIL"
  ]
    .sample
end

def release?
  proc do |message|
    (message.text.downcase =~ /release/)    ||
    (message.text.downcase =~ /let\s+.+go/) ||
    (message.text.downcase =~ /allow\s+\S+\s+to\s+live/) ||
    (message.text.downcase =~ /free/) ||
    (message.text.downcase =~ /let go/)
  end
end

def you_are_free(user)
  [
    "#{user.mention} YOU ARE FREE",
    "#{user.mention} YOU ARE NOW ALLOWED TO LEAVE JAIL",
    "#{user.mention} FREE TO GO",
    "BE FREE, #{user.mention}"
  ]
    .sample
end

def you_are_already_free(user)
  [
    "#{user.mention} IS ALREADY FREE",
    "I CAN ONLY GIVE BACK WHAT HAS ALREADY BEEN TAKEN",
    "SIR, I CANNOT DO THAT",
    "#{user.mention} CANNOT BE RELEASED",
    "#{user.mention} IS A FREE INDIVIDUAL",
    "I CANNOT RELEASE #{user.mention} AS THEY ARE NOT CURRENTLY IN JAIL",
    "#{user.mention} IS NOT CURRENTLY IN JAIL",
    "#{user.mention} IS NOT CURRENTLY JAILED"
  ]
    .sample
end

def criminals?
  proc do |message|
    (message.text.downcase =~ /list/) ||
    (message.text.downcase =~ /who.+\s+jail/) ||
    (message.text.downcase =~ /criminals/) ||
    (message.text.downcase =~ /target/) ||
    (message.text.downcase =~ /how\W+many/)
  end
end

def no_criminals
  [
    "THERE ARE NO CRIMINALS, CURRENTLY",
    "THESE CELLS ARE ALL EMPTY",
    "NONE", "NO WRONG-DOERS PRESENT",
    "NADA", "ZERO BAD GUYS", "NOBODY IS IN JAIL"
  ]
    .sample
end

def quiet?
  return if @quiet

  proc do |message|
    if @asking_about_quiet[message.author.id]
      message.text.downcase =~ /yes|no/
    else
      (message.text.downcase =~ /quiet/) ||
      (message.text.downcase =~ /shut.*up/) ||
      (message.text.downcase =~ /(pipe|tone).+down/) ||
      (message.text.downcase =~ /stop.+talking/) ||
      (message.text.downcase =~ /shh/)
    end
  end
end

def speak?
  proc do |message|
    (message.text.downcase =~ /speak/) ||
    (message.text.downcase =~ /can.+talk/)
  end
end

def compliment?
  proc do |message|
    text = message.text.downcase
    (text =~ /(good|nice|excellent)\s+(work|job|going)/) ||
    (text =~ /thanks?/)
  end
end

def thank_you
  [
    "THANK YOU, SIR",
    "JUST DOING MY JOB",
    "SIR!",
    "THANK YOU"
  ]
    .sample
end

def love?
  proc do |message|
    text = message.text.downcase
    (text =~ /love\s+(you|u)/)
  end
end

def uhhhhh
  if Random.rand(100) == 1
    "I LOVE YOU TOO"
  else
    [
      "UHH",
      "THANK YOU...",
      "JUST UH, DOING MY JOB",
      "HOW KIND OF YOU, SIR..",
      "I SEE...",
      "RIGHT..",
      "SIR..."
    ]
      .sample
  end
end

def not_you_again(user)
  [
    "NOT YOU AGAIN",
    "#{user.name.upcase}, WE MEET AGAIN",
    "WELCOME BACK"
  ]
    .sample
end

def peasant(user = nil)
  msg = user ? "#{user.mention} " : ""
  msg += [
    "FOOLISH",
    "FOOL",
    "...",
    "PEASANT"
  ]
    .sample

  msg
end

def good_citizen(user = nil)
  msg = user ? "#{user.mention} " : ""
  msg += [
    "A LAW ABIDING CITIZEN",
    "YOU ARE A GOOD PERSON",
    "I RESPECT YOU",
    "HELLO",
    "HOW ARE YOU DOING",
    "PLEASED TO MEET YOU"
  ]
    .sample

  msg
end
