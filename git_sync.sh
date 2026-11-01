#!/bin/bash
# 添削・字幕取得の結果をGitHubへ自動反映（変更がある時だけcommit/push）
cd /Users/kuri1/claude/taitsu-trade || exit 1
export PATH="/Users/kuri1/.local/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"
git add -A
if ! git diff --cached --quiet; then
  git commit -qm "自動反映 $(date '+%Y-%m-%d %H:%M')"
fi
git remote get-url origin >/dev/null 2>&1 || exit 0
# クラウド側の編集（ルール文書など）を先に取り込んでから push する
git pull -q --rebase origin main || { git rebase --abort 2>/dev/null; exit 1; }
for i in 1 2 3 4; do
  git push -q origin main && exit 0
  sleep $((2**i))
done
exit 1
