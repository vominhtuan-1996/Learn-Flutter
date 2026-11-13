#!/usr/bin/env python3
"""Dọn nhánh git local mà nhánh remote tương ứng đã bị xoá khỏi origin.

Mặc định chỉ LIỆT KÊ (dry-run). Xoá khi có `--delete`. Không bao giờ xoá: nhánh đang checkout (kể cả ở worktree khác),
nhánh được bảo vệ (main/master/develop/dev/staging/production/*/release/*), và nhánh chưa merge vào nhánh gốc trừ khi
được nêu đích danh qua `--force`.

  python3 prune_gone_branches.py [--repo PATH] [--no-fetch] [--include-local-only] [--delete] [--force NAME ...]

Nhóm nhánh:
  gone        có upstream nhưng upstream đã bị xoá trên origin (`[gone]` sau `git fetch --prune`)
  local-only  không có upstream (có thể chưa từng push); chỉ xét khi có `--include-local-only`
"""
import argparse
import fnmatch
import subprocess
import sys
from pathlib import Path

PROTECTED = ["main", "master", "develop", "dev", "production/*", "staging/*", "release/*"]


def git(repo, *args, check=True):
    res = subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True)
    if check and res.returncode != 0:
        sys.exit(f"git {' '.join(args)} lỗi: {res.stderr.strip() or res.stdout.strip()}")
    return res


def base_ref(repo):
    """Nhánh gốc để so merge.

    LearnFlutter: MR nào cũng merge vào `dev`, còn origin/HEAD trỏ `main` (chỉ nhận release) — so với `main` thì nhánh đã
    merge vào `dev` bị báo nhầm là chưa merge. Nên ưu tiên origin/dev, rồi mới tới origin/HEAD và main/master.
    """
    head = git(repo, "symbolic-ref", "--quiet", "refs/remotes/origin/HEAD", check=False)
    candidates = ["origin/dev"]
    if head.returncode == 0:
        candidates.append(head.stdout.strip().replace("refs/remotes/", ""))
    candidates += ["origin/main", "origin/master", "dev", "main", "master"]
    for ref in candidates:
        if git(repo, "rev-parse", "--verify", "--quiet", ref, check=False).returncode == 0:
            return ref
    sys.exit("Không tìm thấy nhánh gốc (origin/dev, origin/main, origin/master, dev, main, master).")


def worktree_branches(repo):
    """Nhánh đang được checkout ở bất kỳ worktree nào (kể cả cái hiện tại)."""
    out = git(repo, "worktree", "list", "--porcelain").stdout
    return {line.split("refs/heads/", 1)[1] for line in out.splitlines() if line.startswith("branch refs/heads/")}


def is_protected(name):
    return any(fnmatch.fnmatch(name, pat) for pat in PROTECTED)


def classify(repo):
    rows = git(repo, "for-each-ref", "--format=%(refname:short)\t%(upstream:short)\t%(upstream:track)", "refs/heads").stdout
    gone, local_only = [], []
    for line in rows.splitlines():
        name, upstream, track = (line.split("\t") + ["", ""])[:3]
        if "[gone]" in track:
            gone.append(name)
        elif not upstream:
            local_only.append(name)
    return gone, local_only


def describe(repo, name, base):
    merged = git(repo, "merge-base", "--is-ancestor", name, base, check=False).returncode == 0
    unique = int(git(repo, "rev-list", "--count", f"{base}..{name}").stdout.strip() or 0)
    last = git(repo, "log", "-1", "--format=%ad %s", "--date=short", name).stdout.strip()[:60]
    return merged, unique, last


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--repo", default=".", help="thư mục repo (mặc định: thư mục hiện tại)")
    ap.add_argument("--no-fetch", action="store_true", help="không chạy `git fetch --prune origin`")
    ap.add_argument("--include-local-only", action="store_true", help="xét cả nhánh không có upstream (đã merge)")
    ap.add_argument("--delete", action="store_true", help="xoá các nhánh an toàn (đã merge); không có cờ này chỉ liệt kê")
    ap.add_argument("--force", nargs="+", default=[], metavar="NAME", help="xoá cả nhánh CHƯA merge, nêu đích danh")
    args = ap.parse_args()

    repo = Path(args.repo).resolve()
    git(repo, "rev-parse", "--git-dir")
    if not args.no_fetch:
        pruned = git(repo, "fetch", "--prune", "origin").stderr.strip()
        if pruned:
            print(pruned)
    base = base_ref(repo)
    gone, local_only = classify(repo)
    checked_out = worktree_branches(repo)

    pool = [(n, "gone") for n in gone]
    if args.include_local_only:
        pool += [(n, "local-only") for n in local_only]
    safe, blocked = [], []
    print(f"Repo: {repo}\nNhánh gốc để so merge: {base}\n")
    print(f"{'NHÁNH':<56} {'LOẠI':<11} {'MERGED':<7} {'RIÊNG':<6} GHI CHÚ")
    for name, kind in sorted(pool):
        merged, unique, last = describe(repo, name, base)
        if name in checked_out:
            note, ok = "đang checkout, bỏ qua", False
        elif is_protected(name):
            note, ok = "nhánh được bảo vệ, bỏ qua", False
        elif merged:
            note, ok = "xoá được", True
        elif name in args.force:
            note, ok = "CHƯA merge, xoá vì --force", True
        else:
            note, ok = f"CHƯA merge, giữ lại ({last})", False
        print(f"{name:<56} {kind:<11} {'yes' if merged else 'NO':<7} {unique:<6} {note}")
        (safe if ok else blocked).append(name)

    unknown = [n for n in args.force if n not in {p[0] for p in pool}]
    if unknown:
        print(f"\n--force bỏ qua (không thuộc nhóm đang xét): {', '.join(unknown)}")
    if not pool:
        print("(không có nhánh nào thuộc nhóm đang xét)")
    if not args.delete:
        print(f"\nDry-run: {len(safe)} nhánh sẽ xoá, {len(blocked)} giữ lại. Thêm --delete để xoá.")
        return
    deleted = 0
    for name in safe:
        # Đã tự kiểm merge vào nhánh gốc ở trên (hoặc --force) nên dùng -D: `-d` có thể từ chối khi HEAD local đang tụt hậu.
        res = git(repo, "branch", "-D", name, check=False)
        print(("Đã xoá " + name) if res.returncode == 0 else f"Không xoá được {name}: {res.stderr.strip()}")
        deleted += res.returncode == 0
    print(f"\nĐã xoá {deleted}/{len(safe)}; giữ lại {len(blocked)}.")


if __name__ == "__main__":
    main()
