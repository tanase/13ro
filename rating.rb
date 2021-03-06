# -*- coding: utf-8 -*-
require "yaml"
require "fileutils"
require "./elo"

DBFILE = "db.yaml"
FileUtils.cp(DBFILE, DBFILE + ".bak")
DEFAULT_PENALTY = 20
$db = YAML.load_file(DBFILE) || {users: [], penalty: DEFAULT_PENALTY}
DEFAULT_RATING = 1500

def usage
  puts "See readme.txt"
  exit 1
end

def find(name)
  for player in $db[:users]
    if player[:name] == name
      return player
    end
  end
  return nil
end

def storeDB
  File.open(DBFILE, "w") do |f|
    f.write $db.to_yaml
  end
end

def register(args, prompt)
  if args.size != 2 && args.size != 3
    usage
  end

  name = args[0]

  if find(name)
    puts "#{name} already exists"
    return
  end
  
  nickname = args[1]
  rating = DEFAULT_RATING
  if args.size == 3
    rating = args[2].to_i
  end
  
  puts "name:#{name} nickname:#{nickname} rating:#{rating}"
  if prompt
    puts "Is it OK to proceed? (y/n)"
  end
  
  if !prompt || STDIN.gets.chomp == "y"
    $db[:users].push({name: name, nickname: nickname, rating: rating, win: 0, loss: 0, draw: 0})
    storeDB
  end
end

def result(args)
  if args.size != 3 && args.size != 4
    usage
  end

  names = [args[0], args[1]]
  result = args[2].to_i
  handicap = 0
  handicap = args[3].to_i if args.size == 4
  $db[:penalty] ||= DEFAULT_PENALTY
  orgPenalty = $db[:penalty]
  handicapPoint = handicap * orgPenalty

  players = [find(names[0]), find(names[1])]
  
  for i in 0 ... 2
    if !players[i]
      puts "Player #{names[i]} not found."
      return
    end
  end

  # 黒が下手であることのチェック
  if handicap > 0 && players[0][:rating] >= players[1][:rating]
    puts "Higher rated player is given handicap!"
    return
  end

  newRatings = [players[0][:rating], players[1][:rating]]
  
  scores = [0.5, 0.5]
  if result == 1
    scores = [1, 0]
  elsif result == 0
    scores = [0, 1]
  end

  newPenalty = newHandicapPenalty(orgPenalty, handicap, newRatings[0], newRatings[1], result[0])
  $db[:penalty] = newPenalty

  for i in 0 ... 2
    me = players[i]
    opp = players[1-i]
    
    win = me[:win]
    oppWin = opp[:win]
    
    loss = me[:loss]
    oppLoss = opp[:loss]
    
    draw = me[:draw]
    oppDraw = opp[:draw]

    played = win + loss + draw
    oppPlayed = oppWin + oppLoss + oppDraw
    
    rating = me[:rating]
    oppRating = opp[:rating]
    
    newRatings[i] += scores[i] * changeOnWin(rating, played, loss, oppRating, oppPlayed, oppLoss, handicapPoint)
    newRatings[i] += scores[1-i] * changeOnLoss(rating, played, loss, oppRating, oppPlayed, oppLoss, handicapPoint)
  end

  for i in 0 ... 2
    puts "#{names[i]} #{players[i][:rating]} => #{newRatings[i]}"
    if scores[i] == 1
      players[i][:win] += 1
    elsif scores[i] == 0
      players[i][:loss] += 1
    elsif scores[i] == 0.5
      players[i][:draw] += 1
    end
    players[i][:rating] = newRatings[i]
  end

  storeDB
end

def komi(args)
  if args.size != 2
    usage
  end

  names = [args[0], args[1]]
  players = [find(names[0]), find(names[1])]
  for i in 0 ... 2
    if !players[i]
      puts "Player #{names[i]} not found."
      return
    end
  end
  
  penalty = $db[:penalty] || DEFAULT_PENALTY
  res = ((players[0][:rating] - players[1][:rating]).abs / penalty).to_i
  lower = players[0][:rating] <= players[1][:rating] ? 0 : 1
  puts "Komi=#{res}"
  puts "Black:#{names[lower]} White:#{names[1-lower]}(#{6-res})"
end

def main
  if ARGV.size < 2
    usage
  end
  
  command = ARGV[0]

  if command == "register"
    register(ARGV[1 ... ARGV.size], true)
    
  elsif command == "register_noprompt"
    register(ARGV[1 ... ARGV.size], false)
    
  elsif command == "result"
    result(ARGV[1 ... ARGV.size])

  elsif command == "komi"
    komi(ARGV[1 ... ARGV.size])

  else
    puts "Unknown command #{command}"
    usage
  end
end

main
