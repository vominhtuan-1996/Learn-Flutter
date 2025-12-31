#!/bin/bash
# xoá cache rồi update shorebird khi lỗi 
# rm -rf ~/.shorebird/bin/cache
# shorebird upgrade
echo "==========================="
echo "  Shorebird Build Script"
echo "==========================="

choice=$(gum choose "Release" "Patch" "Preview" "Exit")

case $choice in
  "Release")
    echo "👉 Running Shorebird Release..."
    flutter clean
    source shore_bird_ci_cd/shorebird.env 
    
    yes | shorebird release ios --flutter-version=3.27.4 --no-codesign
    cd ios || exit
    fastlane shorebird_release
    ;;
  "Patch")
    echo "👉 Running Shorebird Patch..."
    source shore_bird_ci_cd/shorebird.env 
    shorebird patch ios --no-codesign
    # -- --version 3.27.4 --no-codesign
    cd ios || exit
    fastlane shorebird_release
    ;;
  "Preview")
    echo "Fetching releases..."
releases=$(shorebird releases list | awk '{print $1}' | tail -n +2)

echo "Which release would you like to preview?"
select version in $releases; do
  if [ -n "$version" ]; then
    shorebird preview --release-version=$version
    break
  else
    echo "Invalid option"
  fi
done
    ;;
 
 
  "Exit")
    echo "👋 Bye!"
    ;;
esac


# #!/bin/bash
# echo "Fetching releases..."
# releases=$(shorebird releases list | awk '{print $1}' | tail -n +2)

# echo "Which release would you like to preview?"
# select version in $releases; do
#   if [ -n "$version" ]; then
#     shorebird preview --release-version=$version
#     break
#   else
#     echo "Invalid option"
#   fi
# done
