# タイツ式トレード理論

YouTubeチャンネル「タイツ」（https://www.youtube.com/@all_tesla）の配信ログから、投資理論を条件文のルールとして取り出すプロジェクト。進め方は `kurienator/cleartrade` と同じ。

## 流れ
1. `list_videos.sh` で全動画を `video_list.tsv` に列挙（Mac mini で手動実行）
2. `fetch_batch.sh` が日本語字幕を古い順に少しずつ取得し、`vtt2txt.py` で `transcripts/` に保存（launchd、3時間ごと）
3. `scripts/light_clean.py` で置換表とフィラー除去だけの軽い添削 → `cleaned/`
4. `discussion/00_roles.md` の6役が期間ごとに議論 → `rules_provisional.md`・`open_issues.md`・`verification_plan.md`
5. `git_sync.sh` が変更を自動で commit/push（launchd、12時間ごと）

## 自動取得の開始（まだ実行しない）
```
cp launchd/com.kuri1.taitsu.*.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.kuri1.taitsu.fetch.plist
launchctl load ~/Library/LaunchAgents/com.kuri1.taitsu.gitsync.plist
```
