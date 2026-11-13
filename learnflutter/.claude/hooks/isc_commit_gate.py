#!/usr/bin/env python3
"""Reject Claude Code commits that violate ISC commit and branch rules."""

import json
import re
import shlex
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TYPES = "feat|fix|hotfix|refactor|test|docs|ci|chore|perf|security"
BRANCH_TYPES = "feature|bugfix|hotfix|refactor|test|chore|perf|security"
HEADER = re.compile(rf"^({TYPES})(?:\(([a-z][a-z0-9._/-]*)\))?(!)?: (.+)$")
BRANCH = re.compile(
    rf"^({BRANCH_TYPES})/([A-Za-z0-9]+(?:-[A-Za-z0-9]+)*-\d+)-([a-z0-9]+(?:-[a-z0-9]+)*)$"
)
RELEASE = re.compile(r"^release/[a-z0-9][a-z0-9.-]*$")
NON_IMPERATIVE = {
    "added", "adding", "changed", "changing", "documented", "fixed", "fixes",
    "implemented", "improved", "refactored", "removed", "resolved", "tested", "updated",
}
COMMIT_COMMAND = re.compile(
    r"(?:^|&&|\|\||[;\n])\s*(?:[A-Za-z_][A-Za-z0-9_]*=\S+\s+)*"
    r"git(?:\s+-[Cc]\s+\S+)*\s+commit\b"
)


def git(*args):
    result = subprocess.run(["git", *args], cwd=ROOT, check=True, capture_output=True, text=True)
    return result.stdout.strip()


def validate_branch(branch):
    if not branch or branch in {"main", "master", "develop"}:
        return "Blocker: không commit trực tiếp lên main/master/develop hoặc detached HEAD"
    if RELEASE.fullmatch(branch):
        return None
    match = BRANCH.fullmatch(branch)
    if not match:
        return "Blocker: branch phải là <type>/<request-id>-<kebab-description> theo ISC"
    if len(match.group(3)) > 50:
        return "Blocker: phần mô tả branch phải dài tối đa 50 ký tự"
    return None


def validate_message(message, ai_assisted=True):
    message = message.rstrip("\n")
    if len(message) > 500:
        return "Blocker: commit message dài quá 500 ký tự"
    header = message.split("\n", 1)[0]
    match = HEADER.fullmatch(header)
    if not match:
        return "Blocker: commit phải theo <type>(<scope>): <subject> với type ISC cho phép"
    subject = match.group(4)
    if len(subject) > 72:
        return "Blocker: subject dài quá 72 ký tự"
    if ai_assisted and not subject.endswith(" [AI]"):
        return "Blocker: commit do Claude hỗ trợ phải có [AI] ở cuối subject"
    plain_subject = subject.removesuffix(" [AI]")
    if not plain_subject or plain_subject.endswith("."):
        return "Blocker: subject không được rỗng hoặc kết thúc bằng dấu chấm"
    if not plain_subject.isascii():
        return "Blocker: subject phải viết bằng tiếng Anh không dấu"
    first_word = plain_subject.split()[0]
    if first_word != first_word.lower() or first_word.lower() in NON_IMPERATIVE:
        return "Blocker: subject phải bắt đầu bằng động từ mệnh lệnh chữ thường"
    if plain_subject.lower() in {"wip", "update code", "fix bug", "add feature"}:
        return "Blocker: subject quá chung chung, cần mô tả thay đổi cụ thể"
    return None


def commit_message_from_command(command, cwd):
    if any(token in command for token in ("$(", "`")):
        raise ValueError("Dùng git commit -m hoặc -F với nội dung tường minh, không dùng shell substitution")
    parser = shlex.shlex(command, posix=True, punctuation_chars=";&|<>()")
    parser.whitespace_split = True
    tokens = list(parser)
    if any(token in {";", "&&", "||", "|", "&", "<", ">", ">>", "(", ")"} for token in tokens):
        raise ValueError("Chạy git commit bằng lệnh riêng để hook kiểm tra chính xác")
    if tokens[:2] != ["git", "commit"]:
        raise ValueError("Chỉ hỗ trợ lệnh git commit trực tiếp")
    parts = []
    file_path = None
    i = 2
    while i < len(tokens):
        token = tokens[i]
        if token in {"-m", "--message", "-F", "--file"}:
            if i + 1 >= len(tokens):
                raise ValueError(f"Thiếu giá trị cho {token}")
            if token in {"-m", "--message"}:
                parts.append(tokens[i + 1])
            else:
                file_path = tokens[i + 1]
            i += 2
            continue
        if token.startswith("--message="):
            parts.append(token.split("=", 1)[1])
        elif token.startswith("--file="):
            file_path = token.split("=", 1)[1]
        elif token.startswith("-m") and len(token) > 2:
            parts.append(token[2:])
        elif token.startswith("-F") and len(token) > 2:
            file_path = token[2:]
        elif token in {"--no-edit", "--fixup", "--squash"} or token.startswith(("--fixup=", "--squash=")):
            raise ValueError("Dùng -m hoặc -F để khai báo commit message đúng rule ISC")
        i += 1
    if file_path and parts:
        raise ValueError("Chỉ dùng một nguồn commit message: -m hoặc -F")
    if file_path:
        path = Path(file_path)
        if not path.is_absolute():
            path = Path(cwd) / path
        return path.read_text(encoding="utf-8")
    if parts:
        return "\n\n".join(parts)
    raise ValueError("Thiếu commit message; dùng git commit -m '...' hoặc git commit -F <file>")


def deny(reason):
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": reason,
    }}, ensure_ascii=False))


def main():
    event = json.load(sys.stdin)
    if event.get("hook_event_name") != "PreToolUse":
        return
    command = event.get("tool_input", {}).get("command", "")
    if not COMMIT_COMMAND.search(command):
        return
    try:
        branch_error = validate_branch(git("branch", "--show-current"))
        if branch_error:
            deny(branch_error)
            return
        message = commit_message_from_command(command, event.get("cwd") or ROOT)
        message_error = validate_message(message)
        if message_error:
            deny(message_error)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        deny(f"Blocker: không kiểm tra được commit theo ISC: {error}")


if __name__ == "__main__":
    main()
