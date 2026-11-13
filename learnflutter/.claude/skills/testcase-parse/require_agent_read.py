#!/usr/bin/env python3
"""PreToolUse(Bash) hook: chặn chạy parse_testcase.py nếu session chưa Read AGENT.md của skill."""
import json, sys

data = json.load(sys.stdin)
if "parse_testcase.py" not in str(data.get("tool_input", {}).get("command", "")):
    sys.exit(0)

try:
    with open(data["transcript_path"], encoding="utf-8") as f:
        for line in f:
            if "testcase-parse/AGENT.md" not in line:
                continue
            msg = json.loads(line).get("message", {})
            content = msg.get("content")
            for b in content if isinstance(content, list) else []:
                if b.get("type") == "tool_use" and b.get("name") == "Read" \
                        and str(b.get("input", {}).get("file_path", "")).endswith("testcase-parse/AGENT.md"):
                    sys.exit(0)
except (OSError, KeyError, json.JSONDecodeError):
    pass  # ponytail: không đọc được transcript -> chặn (fail closed), user đọc AGENT.md rồi chạy lại

print("Chặn: phải Read .claude/skills/testcase-parse/AGENT.md trước khi chạy parse_testcase.py, "
      "rồi hỏi user folder version / file testcase / folder output.", file=sys.stderr)
sys.exit(2)
