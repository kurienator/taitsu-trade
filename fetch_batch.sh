#!/bin/bash
# 1日8回（3時間ごと）実行: 未取得のライブを古い順に最大 LIMIT 本、間隔を空けて字幕取得→テキスト化する
cd /Users/kuri1/claude/taitsu-trade || exit 1
Y=/Users/kuri1/Library/Python/3.9/bin/yt-dlp
LIMIT=${LIMIT:-100}
LOG=logs/$(date +%Y%m%d).log
LOCK=logs/.lock
mkdir "$LOCK" 2>/dev/null || { echo "$(date) already running" >> "$LOG"; exit 0; }
trap 'rmdir "$LOCK"' EXIT
touch nosubs.tsv failed.tsv logs/fetch_log.tsv
log(){ printf '%s\t%s\t%s\t%s\n' "$(date "+%F %T")" "$1" "$2" "$3" >> logs/fetch_log.tsv; }

n=0; fails=0
for id in $(tail -r video_list.tsv | cut -f1); do
  [ "$n" -ge "$LIMIT" ] && break
  ls subs/*_"$id".ja.vtt >/dev/null 2>&1 && continue
  grep -q "^$id	" nosubs.tsv && continue
  [ "$(grep -c "^$id	" failed.tsv)" -ge 3 ] && continue
  [ "$n" -gt 0 ] && sleep $((60 + RANDOM % 121))
  n=$((n+1))
  out=$("$Y" --skip-download --write-auto-subs --write-subs --sub-langs ja --sub-format vtt \
        --extractor-args "youtube:player_client=android" \
        -o "subs/%(upload_date)s_%(id)s.%(ext)s" "https://www.youtube.com/watch?v=$id" 2>&1)
  vtt=$(ls subs/*_"$id".ja.vtt 2>/dev/null | head -1)
  if [ -n "$vtt" ]; then
    /usr/bin/python3 -I vtt2txt.py "$vtt" "transcripts/$(basename "$vtt" .vtt).txt" >> "$LOG"
    log OK "$id" "$(basename "$vtt")"
    fails=0
  elif echo "$out" | grep -q "ERROR"; then
    err=$(echo "$out" | grep ERROR | head -1)
    printf '%s\t%s\t%s\n' "$id" "$(date +%F)" "$err" >> failed.tsv
    echo "$(date) FAIL $id $err" >> "$LOG"
    log FAIL "$id" "$err"
    if echo "$err" | grep -qiE "429|sign in|bot|rate"; then fails=$((fails+1)); else fails=0; fi
    # レート制限・ボット判定の疑いがあれば当日は打ち切る
    if [ "$fails" -ge 2 ]; then
      echo "$(date) STOP for today (fails=$fails)" >> "$LOG"; break
    fi
  else
    printf '%s\t%s\n' "$id" "$(date +%F)" >> nosubs.tsv
    echo "$(date) NOSUBS $id" >> "$LOG"
    log NOSUBS "$id" ""
  fi
done
echo "$(date) done: attempted=$n total_vtt=$(ls subs/*.vtt | wc -l)" >> "$LOG"
