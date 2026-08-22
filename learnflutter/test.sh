#!/bin/bash
RESET="\033[0m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
function show_progress {
    message=$1
    start_time=$(date +%s.%N)
    end_time=$(date +%s.%N)
    elapsed_seconds=$(echo "$end_time - $start_time" | bc)
    echo "✓ Elapsed time: $elapsed_seconds seconds"
}

function run_with_timer() {
    local task="$1"
    local message="$2"
    local start_time=$(date +%s.%N)

    $task
    local end_time=$(date +%s.%N)
    local elapsed_time=$(echo "$end_time - $start_time" | bc)

    echo -e $message $BLUE ${elapsed_time}s.
}

# Get the current timestamp in seconds


# Simulate some task (replace with your actual task)
# run_with_timer "flutter build ios lib/main.dart" "$BLUE  Building for done...$RESET"y

run_with_timer "fastlane build_ios scheme:"${scheme}" output:"${output}" provisioningProfile:"${provisioningProfile}" bundleID:"${bundleID}"" "$BLUE  Building IPA for done...$RESET"

  
# start_time=$SECONDS
#     # Gọi hàm
# sleep 20
#   # Tính toán thời gian thực thi
# end_time=$SECONDS
# elapsed_time=$((end_time - start_time))
# echo "Thời gian thực thi: ${elapsed_time}s"
# Get the current timestamp in seconds


# Calculate the elapsed time in seconds


# Extract milliseconds

# echo 

# Lưu thời điểm bắt đầu
# start_time=$SECONDS

# Gọi hàm



# Tính toán thời gian thực thi
# end_time=$SECONDS
# elapsed_time=$((end_time - start_time))

# echo "Thời gian thực thi: $elapsed_time giây"

# Sử dụng hàm để mô phỏng quá trình tải
# show_progress "Fetching apps" 2
# show_progress "Fetching releases" 1
# show_progress "Fetching xcframework artifact" 1
# show_progress "Fetching ios_framework_supplement artifact" 1
# show_progress "Downloading xcframework (100%)" 20
# show_progress "Downloading ios_framework_supplement (100%)" 1
# show_progress "Building patch with Flutter 3.24.5 (3faf56aafa)..." 34