#!/usr/bin/env python3
"""軽い添削: transcripts/ にあって cleaned/ に無い回を、_replace.tsv の単純置換とフィラー除去だけで cleaned/ に保存する。
文章の書き直しはしない。既存ファイルは上書きしない。"""
import re
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
TRANS = BASE / "transcripts"
CLEAN = BASE / "cleaned"

FILLERS = ["えーっと", "えっと", "えーと", "えー", "あのー", "あの", "まあ", "まぁ", "うーん", "んー"]


def load_replace():
    pairs = []
    path = CLEAN / "_replace.tsv"
    if path.exists():
        for line in path.read_text(encoding="utf-8").splitlines():
            if not line.strip() or line.startswith("#"):
                continue
            parts = line.split("\t")
            if len(parts) >= 2 and parts[0]:
                pairs.append((parts[0], parts[1]))
    pairs.sort(key=lambda p: -len(p[0]))
    return pairs


def load_titles():
    titles = {}
    path = BASE / "video_list.tsv"
    if path.exists():
        for line in path.read_text(encoding="utf-8").splitlines():
            parts = line.split("\t")
            if len(parts) >= 2:
                titles[parts[0]] = parts[1]
    return titles


def strip_fillers(text):
    # 句読点・空白・行頭に挟まれた独立したフィラーだけを消す
    pat = "|".join(re.escape(f) for f in FILLERS)
    text = re.sub(r"(?:(?<=^)|(?<=[\s、。]))(?:" + pat + r")[、,]?\s*(?=\S|$)", "", text, flags=re.M)
    text = re.sub(r"[ \t　]{2,}", " ", text)
    return text


def main():
    pairs = load_replace()
    titles = load_titles()
    made = []
    for src in sorted(TRANS.glob("*.ja.txt")):
        key = src.name[: -len(".ja.txt")]
        dst = CLEAN / f"{key}.md"
        if dst.exists():
            continue
        date, vid = key.split("_", 1)
        body = src.read_text(encoding="utf-8")
        for wrong, right in pairs:
            body = body.replace(wrong, right)
        body = strip_fillers(body).strip()
        title = titles.get(vid, "")
        head = f"# {date[:4]}-{date[4:6]}-{date[6:]} {title}\n\n- 元動画: https://www.youtube.com/watch?v={vid}\n\n"
        dst.write_text(head + body + "\n", encoding="utf-8")
        made.append(dst.name)
    for m in made:
        print(m)
    print(f"作成 {len(made)} 本", file=sys.stderr)


if __name__ == "__main__":
    main()
