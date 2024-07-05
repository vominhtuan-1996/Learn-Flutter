# Màu sắc cho terminal (CMD không hỗ trợ quá nhiều màu sắc)
function Write-Color {
    param (
        [string]$Text,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Host $Text
    $Host.UI.RawUI.ForegroundColor = [ConsoleColor]::White
}

# Current project dir
$CURRENT_DIR = Get-Location

# Thông tin về GitHub repository
$GITHUB_REPO = "https://github.com/MobileTeamSU12/Mobimap_Install_mobimap.git"

$GITHUB_DIR = "D:\Dev\PJ\mobi_install\Mobimap_Android_install\flutter" # Thay đổi đường dẫn local repos
$GITHUB_DIR_RELEASE = "D:\Dev\PJ\mobi_install\Mobimap_Android_install\release" # Thay đổi đường dẫn local repos

$APK_DIR_STAG = "$CURRENT_DIR\build\app\outputs\apk\stag\release"
$APK_DIR_PROD = "$CURRENT_DIR\build\app\outputs\apk\prod\release"

# Telegram Bot Token và Chat ID
$TELEGRAM_BOT_TOKEN="7320246267:AAEWMv8pNBxVXBMSk-pRwWS38Upet5SmfMw" # Thay token của mày
$TELEGRAM_CHAT_ID="-4277408521"     # Thay Chat ID của mày
$HTTP_DOWNLOAD_GITPAGE = "https://mobileteamsu12.github.io/flutter/index.html"

# Hàm log với màu sắc
function log {
    param (
        [string]$message,
        [ConsoleColor]$color
    )
    $timestamp = Get-Date -Format "[HH:mm:ss]"
    Write-Color "$timestamp $message" $color
}


# Hàm gửi thông báo qua Telegram
function Send-TelegramNotification {
    param (
        [string]$message
    )
    $url = "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage"
    $parameters = @{
        chat_id    = $TELEGRAM_CHAT_ID
        text       = $message
        parse_mode = "Markdown"
    }
    Invoke-RestMethod -Uri $url -Method Post -Body $parameters
}

# Hàm tạo short link bằng TinyURL API
function Create-ShortLink {
    param (
        [string]$long_url
    )
    $url ="http://tinyurl.com/api-create.php?url=$long_url"
    $short_link = Invoke-RestMethod -Uri $url
    return $short_link
}

# Hàm build và đẩy lên GitHub
function Build-AndPush {
    param (
        [string]$scheme,
        [string]$output,
        [string]$target_dir,
        [string]$apk_file_dir,
        [string]$env_git
    )

    log "Building for $scheme..." "Blue"

    # Thực hiện build
    flutter build apk --flavor $scheme -t "lib/main_$scheme.dart" --release

    # Đường dẫn đến file pubspec.yaml
    $pubspec_path = "$CURRENT_DIR\pubspec.yaml"

    # Đọc dòng chứa phiên bản từ pubspec.yaml
    $version_line = Select-String -Path $pubspec_path -Pattern '^version: ' | ForEach-Object { $_.Line }

    # Tách phần phiên bản ra khỏi dòng
    $version_full = $version_line -replace 'version: ', ''

    # Tách và lấy phần trước dấu cộng
    $version = $version_full -split '\+' | Select-Object -First 1

    # Hiển thị phiên bản để kiểm tra
    Write-Host "Version Full: $version_full"
    Write-Host "Version: $version"

    log "Building for $scheme done!" "Blue"

    log "APK file now already in: $apk_file_dir" "Yellow"

    cd "$apk_file_dir"

    # Đường dẫn file apk
    $apk_path = "$apk_file_dir\app-$scheme-release.apk"

    $git_hash = (git rev-parse HEAD).Substring(0, 7)
    log "Current Git hash: $git_hash" "Yellow"

    log "APK file path is: $apk_path" "Yellow"
    if (Test-Path $apk_path) {
        Copy-Item -Path "$apk_path" -Destination "$target_dir/$output.apk"

        cd $target_dir
        git add .
        git commit -m "version $version, Git hash: $git_hash"
        git push origin main

        log "APK file is already pushed to GitHub." "Green"

        # Link cài đặt github của team
        $short_link = "https://mobileteamsu12.github.io/flutter/$env_git.html"
        # Link download file APK release
        $release_link = "https://github.com/MobileTeamSU12/Mobimap_Android_install/raw/main/release/MobiMap_v$version.apk"
        # Link trang release
        $short_link_release = "https://mediamap.fpt.vn/mobimap-flutter"

        $notification = "Build $env_git completed successfully.`nNew APK file for version: *$version*`nGit hash: *$git_hash*`nInstall in GitTeam: [$short_link]($short_link)`nDownLoad File APK Release: [$release_link]($release_link)`nInstall APK release: [$short_link_release]($short_link_release)"
        Send-TelegramNotification $notification
    } else {
        log "Error: File APK không tồn tại tại đường dẫn $apk_path." "Red"
#         log "Error: File APK không tồn tại tại đường dẫn $apk_path." "Red"
        Send-TelegramNotification "Build failed. File APK không tồn tại tại đường dẫn $apk_path."
    }
}

# Hiển thị hộp thoại chọn môi trường build
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select Build Environment"
$form.Width = 400
$form.Height = 200

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Width = 300
$listBox.Height = 100
$listBox.Items.AddRange(@("ANDROID_RELEASE", "FIXBUG", "UAT", "CSOC", "TEST"))
$form.Controls.Add($listBox)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Top = 120
$okButton.Left = 150
$okButton.Add_Click({
    $selectedItem = $listBox.SelectedItem
    $form.Close()
    $global:CHOICE = $selectedItem
})

$form.Controls.Add($okButton)
$form.Add_Shown({$form.Activate()})
$form.ShowDialog()

if ($global:CHOICE -ne $null) {
    switch ($global:CHOICE) {
        "ANDROID_RELEASE" {
            Build-AndPush "prod" "MobiMap_v$version" $GITHUB_DIR_RELEASE $APK_DIR_PROD ""
        }
        "FIXBUG" {
            Build-AndPush "prod" "Mobimap_flutter_fix" $GITHUB_DIR $APK_DIR_PROD "index"
        }
        "UAT" {
            Build-AndPush "stag" "Mobimap_flutter_uat" $GITHUB_DIR $APK_DIR_STAG "uat"
        }
        "CSOC" {
            Build-AndPush "stag" "Mobimap_flutter_csoc" $GITHUB_DIR $APK_DIR_STAG "csoc"
        }
        "TEST" {
            Build-AndPush "stag" "Mobimap_flutter_test" $GITHUB_DIR $APK_DIR_STAG "test"
        }
        Default {
            log "Error: Invalid select!" "Red"
        }
    }
} else {
    log "Error: There is no selected environment!" "Red"
}