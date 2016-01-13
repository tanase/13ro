require "./elo"

configs = [
           {played: 10, loss: 3, oppPlayed: 20, oppLoss: 10},
           {played: 50, loss: 3, oppPlayed: 20, oppLoss: 10},
           {played: 100, loss: 3, oppPlayed: 0, oppLoss: 0},
           {played: 10, loss: 3, oppPlayed: 10, oppLoss: 10},
          ]
for config in configs
  puts kValue(config[:played], config[:loss], config[:oppPlayed], config[:oppLoss])
end
