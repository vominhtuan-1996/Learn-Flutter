#!/usr/bin/env bash
# Chạy lần lượt các Maestro flow trong một thư mục và ghi kết quả theo exit code.
# Dùng: run_flows.sh <thư-mục-.maestro> [glob, mặc định tc_*.yaml] [file-kết-quả.tsv]
# Chạy nền khi có nhiều flow (mỗi flow ~30–80s).
set -u
# Máy bận làm driver iOS khởi động chậm; mặc định của Maestro quá ngắn.
export MAESTRO_DRIVER_STARTUP_TIMEOUT="${MAESTRO_DRIVER_STARTUP_TIMEOUT:-180000}"
dir="${1:?thư mục .maestro}"
pattern="${2:-tc_*.yaml}"
out="${3:-${TMPDIR:-/tmp}/maestro-results.tsv}"

cd "$dir" || exit 2
printf 'flow\texit\tseconds\tdebug_dir\n' > "$out"
fail=0
for f in $pattern; do
  [ -e "$f" ] || continue
  start=$(date +%s)
  maestro test "$f" > /tmp/maestro-last.txt 2>&1
  code=$?
  debug=$(grep -m1 -oE '/[^ ]*\.maestro/tests/[0-9_-]+' /tmp/maestro-last.txt || true)
  printf '%s\t%s\t%s\t%s\n' "$f" "$code" "$(( $(date +%s) - start ))" "$debug" | tee -a "$out"
  [ "$code" -eq 0 ] || fail=$((fail + 1))
done
echo "DONE fail=$fail results=$out"
exit "$fail"
