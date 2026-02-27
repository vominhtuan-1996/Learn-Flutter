# project1/.flutter-env
export FLUTTER_ROOT=~/flutter_3.24.7 # Thay đổi đường dẫn này thành đường dẫn thực tế của bạn
export PATH=$FLUTTER_ROOT/bin:$PATH
#run file bằng cú pháp : source ./flutter-env.sh để set flutter sdk của dự án 

# start fix android license
# fix android license
# path sdk android = /Users/tuanios_su12/Library/Android/sdk
# 🔧 1. Cài cmdline-tools
# Mở Terminal trong VSCode và chạy:
# cd /Users/tuanios_su12/Library/Android/sdk # đường dẫn sdk android
# mkdir -p cmdline-tools
# cd cmdline-tools
# tải cmdline-tools từ google
# curl -o commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-mac-10406996_latest.zip
# unzip commandlinetools.zip
# rm commandlinetools.zip
# mv cmdline-tools latest
# end fix android license

# start fix shorebird note match version flutter
#fix shorebird note match version flutter 
# rm -rf ~/.shorebird/bin/cache   
# rm -rf ~/.shorebird/bin/cache/flutter/*
# rm -rf ~/.shorebird/bin/cache/artifacts/*
# shorebird upgrade     
# end fix shorebird note match version flutter

#remove dart_tool and pubspec.lock to fix error not match version build
# rm -rf .dart_tool pubspec.lock 


# export ANDROID_HOME=$HOME/Library/Android/sdk
# export PATH=$PATH:$ANDROID_HOME/platform-tools


# yes | shorebird patch --platforms=ios --flavor=stag --target=lib/main_stag.dart --no-codesign