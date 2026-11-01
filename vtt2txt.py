import re, sys, pathlib
src, dst = map(pathlib.Path, sys.argv[1:3])
out, prev = [], None
for line in src.read_text(encoding="utf-8").splitlines():
    s = line.strip()
    if not s or s.startswith(("WEBVTT","Kind:","Language:","NOTE")) or "-->" in s or s.isdigit():
        continue
    s = re.sub(r"<[^>]+>", "", s).strip()
    if s and s != prev and (not out or s not in out[-3:]):
        out.append(s)
    prev = s
dst.write_text("\n".join(out)+"\n", encoding="utf-8")
print(dst.name, len("".join(out)))
