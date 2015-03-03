・使い方

1. ID登録
> rating register NAME NICKNAME
NAMEは囲碁クエストの名前のようなもので一意のローマ字
NICKNAMEは何でもOK
例)
rating register tanase "棚瀬 寧"

2. 結果登録
> rating result BLACK_NAME WHITE_NAME RESULT [HANDICAP]
例)
白勝ち
rating result foo bar 0
黒勝ちコミのハンディ6(例えば本来白が+6のハンディのところ互先)
rating result foo bar 1 6


・データベース
当面は
db.yaml
に保存
