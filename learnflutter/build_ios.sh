#!/bin/bash
# Import các biến từ file external_config.sh
source $(pwd)/external_config.sh 
# Màu sắc cho terminal
RESET="\033[0m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
# Clear old ipa_path.txt if exist
rm -f ipa_path.txt
# Đọc phiên bản từ pubspec.yaml
version_full=$(grep '^version: ' pubspec.yaml | sed 's/version: //')
version=$(echo $version_full | cut -d "+" -f 1)
# Lấy git hash hiện tại và chỉ lấy 7 ký tự đầu tiên
git_hash_full=$(git rev-parse HEAD)
git_hash=$(echo $git_hash_full | cut -c 1-7)
# Hàm log với timestamp và ký hiệu
log() {
  local message="$1"
  local timestamp=$(date +"[%H:%M:%S]")
  echo -e "${timestamp} ${message}${RESET}"
}
# Hàm gửi thông báo qua Telegram
send_telegram_notification() {
  local message=$1
  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
    -d chat_id=${TELEGRAM_CHAT_ID} \
    -d text="${message}" \
    -d parse_mode="Markdown"
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


# Hàm tạo shortlink
create_short_link_tinyurl() {
  local long_url=$1
  short_link=$(curl -s "http://tinyurl.com/api-create.php?url=${long_url}")
  echo $short_link
}
# Hàm build IPA và đẩy lên GitHub
build_and_push() {
  local scheme=$1
  local output=$2
  local provisioningProfile=$3
  local bundleID=$4
  local target_dir=$5
  local environmentGithub=$6
  log "${BLUE}🔨 Building for ${scheme}...${RESET}"
  run_with_timer "flutter build ios lib/main.dart" "${BLUE}✔️  Building for ${scheme} done...${RESET}"
  # log "${BLUE}✔️  Building for ${scheme} done...${RESET}"
  cd ios
  log "${BLUE}🔨 Building for ${scheme} file IPA...${RESET}"
  if fastlane build_ios scheme:"${scheme}" output:"${output}" provisioningProfile:"${provisioningProfile}" bundleID:"${bundleID}"; then
    log "${GREEN}✔️  Building for ${scheme} file IPA done...${RESET}"
    ipa_path=$(cat ./ipa_path.txt)
    log "${YELLOW}📦 Đường dẫn IPA sau khi build là: $ipa_path${RESET}"
    log "${YELLOW}🔄 Git hash hiện tại là: $git_hash${RESET}"
    if [ -f "$ipa_path" ]; then
      log "${GREEN}📤 Copying IPA file to GitHub directory...${RESET}"
      cp "$ipa_path" "${target_dir}/$output.ipa" # Thay đổi file IPA 
      cd "$target_dir"
      git pull
      git add .
      git commit -m "version $version, Git hash: $git_hash"
      git push origin main
      log "${GREEN}✔️  File IPA đã được đẩy lên GitHub 🎉.${RESET}"
    # Link download file IPA release
      release_link=$(create_short_link_tinyurl "https://github.com/MobileTeamSU12/Mobimap_Install_mobimap/raw/main/IOS_RELEASE/MobiMap_v$version.ipa")
    # Link cài đặt github của team
      short_link="https://mobileteamsu12.github.io/flutter/$environmentGithub.html"
    # Link trang release
      short_link_release=$LINK_RELEASE
    # Format message
      notification=$(printf "Build completed successfully🎉.\nNew IPA file for version *%s*\nGit hash: *%s*\nBản cài đặt ở GitTeam: [%s](%s)\nDownLoad File IPA Release: [%s](%s)\nCài đặt Bản chính thức: [%s](%s)" \
      "$version" "$git_hash" "$short_link" "$short_link" "$release_link" "$release_link" "$short_link_release" "$short_link_release")
      send_telegram_notification "$notification"
    else
      log "${RED}❌ Error: File IPA không tồn tại tại đường dẫn $ipa_path.${RESET}"
      send_telegram_notification "Build failed. File IPA không tồn tại tại đường dẫn $ipa_path."
    fi
  else
    log "${RED}❌ Error: Building for ${scheme} failed.${RESET}"
    send_telegram_notification "Build failed for scheme ${scheme}. Please check the logs for more details."
  fi
}
# Hiển thị popup với danh sách lựa chọn
user_selection=$(zenity --list --title="Chọn môi trường Build IOS" --column="Environment" --column="Description" \
  "IOS_RELEASE" "Bản phát hành chính thức" \
  "FIXBUG" "Sửa lỗi khẩn cấp" \
  "UAT" "Kiểm thử" \
  "CSOC" "An ninh mạng" \
  "TEST" "Thử nghiệm")
# Kiểm tra lựa chọn người dùng và chạy lệnh tương ứng
case "$user_selection" in
  "IOS_RELEASE")
    build_and_push "prod" "MobiMap_v${version}" "$Profile_PROD" "$BundelID_PROD" "$GITHUB_DIR_RELEASE" "index"
    ;;
  "FIXBUG")
    build_and_push "prod" "Mobimap_flutter_fix" "$Profile_PROD" "$BundelID_PROD" "$GITHUB_DIR" "index"
    ;;
  "UAT")
    build_and_push "stag" "Mobimap_flutter_uat" "c$Profile_STAG" "$BundelID_STAG" "$GITHUB_DIR" "uat" 
    ;;
  "CSOC")
    build_and_push "stag" "Mobimap_flutter_csoc" "$Profile_STAG" "$BundelID_STAG" "$GITHUB_DIR" "csoc"
    ;;
  "TEST")
    build_and_push "stag" "Mobimap_flutter_test" "$Profile_STAG" "$BundelID_STAG" "$GITHUB_DIR" "test"
    ;;
  *)
    log "${RED}❌ Error: Lựa chọn không hợp lệ.${RESET}"
    ;;
esac


