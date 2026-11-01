#!/bin/bash
# チャンネルの全動画（通常動画＋ライブ）を列挙して video_list.tsv を作り直す（新しい順）。
# Mac mini で手動実行する。字幕は取得しない。
cd /Users/kuri1/claude/taitsu-trade || exit 1
Y=/Users/kuri1/Library/Python/3.9/bin/yt-dlp
CH="https://www.youtube.com/@all_tesla"
tmp=$(mktemp)
for tab in videos streams; do
  "$Y" --flat-playlist --print "%(id)s	%(title)s	%(upload_date)s" "$CH/$tab" >> "$tmp" 2>/dev/null
  sleep 5
done
awk -F'\t' '!seen[$1]++' "$tmp" > video_list.tsv
rm -f "$tmp"
echo "$(wc -l < video_list.tsv) 本を video_list.tsv に保存"
