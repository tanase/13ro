# -*- coding: utf-8 -*-

P0 = 6                          # P0試合までは
R0 = 140                        # K=R0
P1 = 20                         # P1試合で
R1 = 30                         # K=R1に
OPPP = 15                       # OPPP試合未満の相手の場合は
OPPW = 0.5                      # 重みをOPPWに

def expectedScore(r0, r1)
    return 1.0 / (1 + 10 ** ((r1 - r0) / 400))
end

def kValue(played, loss, oppPlayed, oppLoss)
  k = R1
  # 50勝1敗みたいな人はKを高く維持したい
  # min(played, loss * 8)を取る
  # 50-1だと8試合しかしていないと見る
  # ・・とするとちょっと不安定状態が続きすぎるので、
  # min(played, max(loss * 8, 20)) という条件にするか・・
  modified = loss * 8;
  if (modified < 20)
    modified = 20;
  end
  if (played > modified)
    played = modified;
  end
  
  if (played > P1)
    k = R1
  elsif (played < P0)
    k = R0
  else
    k = 1.0 * ((P1 - played) * R0 + (played - P0) * R1) / (P1 - P0)
  end
  m = 1;
  # 相手が新人の場合、軽めに
  if oppPlayed < OPPP
    m = OPPW + (1 - OPPW) * oppPlayed / OPPP
  end
  return k * m;
end

def toIntrinsic(r, p)
  return r
end

def changeOnWin(ra, pa, lossA, rb, pb, lossB, handicap)
  xra = toIntrinsic(ra, pa)
  xrb = toIntrinsic(rb, pb)
  k = kValue(pa, lossA, pb, lossB)
  if handicap
    if xra < xrb
      xra += handicap
    else
      xrb += handicap
    end
    # ハンディ対局時は低めに(これはお好みで)
    # k *= 0.7
  end
  e = expectedScore(xra, xrb)
  return k * (1.0 - e)
end

# a lost to b
def changeOnLoss(ra, pa, lossA, rb, pb, lossB, handicap)
  xra = toIntrinsic(ra, pa)
  xrb = toIntrinsic(rb, pb)

  k = kValue(pa, lossA, pb, lossB)
  if handicap
    if xra < xrb
      xra += handicap
    else
      xrb += handicap
      # ハンディ対局時は低めに(これはお好みで)
      # k *= 0.7
    end
  end
  e = expectedScore(xra, xrb)
  return -k * e
end

# orgPenalty: コミ一つのレーティング換算
# handicap: コミハンディ数
# rating0: 下手
# rating1: 上手
# result: 1, 0.5, 0 いずれも下手から見た勝敗
M = 0.1
def newHandicapPenalty(orgPenalty, handicap, rating0, rating1, result)
  # 期待勝率
  p = expectedScore(rating0 + orgPenalty * handicap, rating1);
  add = (result - p) * M
  res = orgPenalty + add
  # いくらなんでもという最低ラインを
  res = 5 if res < 5
  return res
end
