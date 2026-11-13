import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("prune_gone_branches.py")


def git(repo, *args):
    res = subprocess.run(
        ["git", "-C", str(repo), "-c", "user.name=t", "-c", "user.email=t@t", "-c", "init.defaultBranch=main", *args],
        capture_output=True, text=True,
    )
    assert res.returncode == 0, f"git {' '.join(args)}: {res.stderr}"
    return res.stdout.strip()


def commit(repo, name):
    (Path(repo) / name).write_text(name, encoding="utf-8")
    git(repo, "add", name)
    git(repo, "commit", "-q", "-m", name)


def run(repo, *args):
    res = subprocess.run([sys.executable, "-I", str(SCRIPT), "--repo", str(repo), "--no-fetch", *args], capture_output=True, text=True)
    return res.returncode, res.stdout


class PruneGoneBranchesTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        base = Path(self.tmp.name)
        self.origin = base / "origin.git"
        self.repo = base / "work"
        subprocess.run(["git", "init", "-q", "--bare", "-b", "main", str(self.origin)], check=True)
        subprocess.run(["git", "clone", "-q", str(self.origin), str(self.repo)], check=True, capture_output=True)
        git(self.repo, "switch", "-q", "-c", "main") if git(self.repo, "branch", "--show-current") != "main" else None
        commit(self.repo, "base")
        git(self.repo, "push", "-q", "-u", "origin", "main")

    def make_branch(self, name, *, merged, pushed=True, remote_deleted=True):
        git(self.repo, "switch", "-q", "-c", name, "main")
        commit(self.repo, name.replace("/", "_"))
        if pushed:
            git(self.repo, "push", "-q", "-u", "origin", name)
        git(self.repo, "switch", "-q", "main")
        if merged:
            git(self.repo, "merge", "-q", "--no-ff", "-m", f"merge {name}", name)
            git(self.repo, "push", "-q", "origin", "main")
        if pushed and remote_deleted:
            git(self.repo, "push", "-q", "origin", "--delete", name)
            git(self.repo, "fetch", "-q", "--prune", "origin")

    def branches(self):
        return set(git(self.repo, "branch", "--format=%(refname:short)").split())

    def test_dry_run_changes_nothing(self):
        self.make_branch("feat/a", merged=True)
        code, out = run(self.repo)
        self.assertEqual(code, 0)
        self.assertIn("feat/a", out)
        self.assertIn("Dry-run", out)
        self.assertIn("feat/a", self.branches())

    def test_deletes_gone_and_merged_only(self):
        self.make_branch("feat/merged", merged=True)
        self.make_branch("feat/unmerged", merged=False)
        run(self.repo, "--delete")
        left = self.branches()
        self.assertNotIn("feat/merged", left)
        self.assertIn("feat/unmerged", left)
        self.assertIn("main", left)

    def test_force_deletes_named_unmerged_branch(self):
        self.make_branch("feat/unmerged", merged=False)
        run(self.repo, "--delete", "--force", "feat/unmerged")
        self.assertNotIn("feat/unmerged", self.branches())

    def test_still_on_origin_is_not_touched(self):
        self.make_branch("feat/live", merged=True, remote_deleted=False)
        run(self.repo, "--delete")
        self.assertIn("feat/live", self.branches())

    def test_local_only_requires_flag(self):
        self.make_branch("feat/local", merged=True, pushed=False)
        run(self.repo, "--delete")
        self.assertIn("feat/local", self.branches())
        run(self.repo, "--delete", "--include-local-only")
        self.assertNotIn("feat/local", self.branches())

    def test_local_only_unmerged_is_kept_even_with_flag(self):
        self.make_branch("feat/wip", merged=False, pushed=False)
        run(self.repo, "--delete", "--include-local-only")
        self.assertIn("feat/wip", self.branches())

    def test_protected_and_current_branch_are_kept(self):
        self.make_branch("staging/v1", merged=True)
        self.make_branch("feat/current", merged=True, remote_deleted=False)
        git(self.repo, "switch", "-q", "feat/current")
        git(self.repo, "push", "-q", "origin", "--delete", "feat/current")
        git(self.repo, "fetch", "-q", "--prune", "origin")
        code, out = run(self.repo, "--delete")
        left = self.branches()
        self.assertIn("staging/v1", left)
        self.assertIn("feat/current", left)
        self.assertIn("đang checkout", out)

    def test_base_is_origin_dev_when_it_exists(self):
        # LearnFlutter: nhánh merge vào dev (không vào main) vẫn phải được coi là đã merge.
        git(self.repo, "switch", "-q", "-c", "dev", "main")
        git(self.repo, "push", "-q", "-u", "origin", "dev")
        git(self.repo, "switch", "-q", "-c", "feat/dev-only", "dev")
        commit(self.repo, "dev_only")
        git(self.repo, "push", "-q", "-u", "origin", "feat/dev-only")
        git(self.repo, "switch", "-q", "dev")
        git(self.repo, "merge", "-q", "--no-ff", "-m", "merge feat/dev-only", "feat/dev-only")
        git(self.repo, "push", "-q", "origin", "dev")
        git(self.repo, "push", "-q", "origin", "--delete", "feat/dev-only")
        git(self.repo, "switch", "-q", "main")
        code, out = run(self.repo, "--delete")
        self.assertIn("origin/dev", out)
        self.assertNotIn("feat/dev-only", self.branches())


if __name__ == "__main__":
    unittest.main()
