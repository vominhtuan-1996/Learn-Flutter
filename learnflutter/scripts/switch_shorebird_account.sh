#!/usr/bin/env bash

# Shorebird Account Switcher
# Allows switching between different Shorebird accounts and their respective app IDs

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
SHOREBIRD_YAML="$PROJECT_ROOT/shorebird.yaml"

# Account registry - add your accounts here
# Format: get_account_by_name returns "APP_ID:EMAIL"

get_account_by_name() {
  local account_name=$1
  case "$account_name" in
    learnflutter)
      echo "c8c81c70-83b7-4984-bbb8-3f722cb13277:tuanvm37@fpt.com"
      ;;
    *)
      echo ""
      ;;
  esac
}

list_all_accounts() {
  echo "learnflutter"
}

# Function: Print usage
usage() {
  cat << EOF
${BLUE}Shorebird Account Switcher${NC}

Usage:
  $(basename "$0") [command] [account_name]

Commands:
  list          List all available accounts
  switch        Switch to an account (interactive if no name provided)
  current       Show current account
  login         Login to Shorebird (auto-detects email from current account)
  logout        Logout from Shorebird
  help          Show this help message

Examples:
  $(basename "$0") list
  $(basename "$0") switch learnflutter
  $(basename "$0") login
  $(basename "$0") current

${YELLOW}Registered Accounts:${NC}
EOF

  for account in $(list_all_accounts); do
    account_info=$(get_account_by_name "$account")
    if [[ -n "$account_info" ]]; then
      app_id="${account_info%:*}"
      email="${account_info#*:}"
      echo "  • $account ($email)"
    fi
  done
}

# Function: Get current app_id from shorebird.yaml
get_current_app_id() {
  if [[ -f "$SHOREBIRD_YAML" ]]; then
    grep "^app_id:" "$SHOREBIRD_YAML" | awk '{print $2}' | tr -d ' '
  fi
}

# Function: List all accounts
list_accounts() {
  echo -e "${BLUE}Available Shorebird Accounts:${NC}\n"
  local current_id=$(get_current_app_id)

  for account in $(list_all_accounts); do
    account_info=$(get_account_by_name "$account")
    if [[ -n "$account_info" ]]; then
      app_id="${account_info%:*}"
      email="${account_info#*:}"
      if [[ "$app_id" == "$current_id" ]]; then
        echo -e "${GREEN}✓${NC} $account"
        echo "  App ID: $app_id"
        echo "  Email:  $email"
      else
        echo "  $account"
        echo "  App ID: $app_id"
        echo "  Email:  $email"
      fi
      echo ""
    fi
  done
}

# Function: Show current account
show_current() {
  local current_id=$(get_current_app_id)

  if [[ -z "$current_id" ]]; then
    echo -e "${YELLOW}No Shorebird app configured${NC}"
    return 1
  fi

  echo -e "${BLUE}Current Shorebird Configuration:${NC}\n"
  echo "App ID: $current_id"

  for account in $(list_all_accounts); do
    account_info=$(get_account_by_name "$account")
    if [[ -n "$account_info" ]]; then
      app_id="${account_info%:*}"
      email="${account_info#*:}"
      if [[ "$app_id" == "$current_id" ]]; then
        echo -e "Account: ${GREEN}$account${NC}"
        echo "Email: $email"
        return 0
      fi
    fi
  done

  echo -e "${YELLOW}(Unknown account - not registered in script)${NC}"
}

# Function: Update shorebird.yaml
update_app_id() {
  local new_app_id=$1
  local new_email=$2
  local account_name=$3

  if [[ ! -f "$SHOREBIRD_YAML" ]]; then
    echo -e "${RED}Error: $SHOREBIRD_YAML not found${NC}"
    return 1
  fi

  # Backup the file
  cp "$SHOREBIRD_YAML" "$SHOREBIRD_YAML.backup"

  # Update app_id
  sed -i '' "s/^app_id: .*/app_id: $new_app_id/" "$SHOREBIRD_YAML"

  echo -e "${GREEN}✓ Updated shorebird.yaml${NC}"
  echo "  Account: $account_name"
  echo "  App ID:  $new_app_id"
  echo "  Email:   $new_email"
  echo -e "\n${BLUE}Next steps:${NC}"
  echo "  1. Run: shorebird logout"
  echo "  2. Run: shorebird login (use email: $new_email)"
  echo "  3. Done!"
}

# Function: Interactive account selection
interactive_switch() {
  echo -e "${BLUE}Available accounts:${NC}\n"

  local count=0
  local -a account_list

  for account in $(list_all_accounts); do
    account_info=$(get_account_by_name "$account")
    if [[ -n "$account_info" ]]; then
      ((count++))
      account_list+=("$account")
      echo "  $count) $account"
    fi
  done

  echo ""
  read -p "Select account (1-$count): " selection

  if [[ $selection -ge 1 ]] && [[ $selection -le $count ]]; then
    local selected="${account_list[$((selection-1))]}"
    switch_account "$selected"
  else
    echo -e "${RED}Invalid selection${NC}"
    return 1
  fi
}

# Function: Switch to account
switch_account() {
  local account_name=$1
  local account_info=$(get_account_by_name "$account_name")

  if [[ -z "$account_info" ]]; then
    echo -e "${RED}Error: Account '$account_name' not found${NC}"
    echo -e "Use '$(basename "$0") list' to see available accounts"
    return 1
  fi

  local app_id="${account_info%:*}"
  local email="${account_info#*:}"

  echo -e "\n${YELLOW}Switching to: $account_name${NC}"
  echo "Email: $email"

  update_app_id "$app_id" "$email" "$account_name"
}

# Function: Login
login_shorebird() {
  local email=$1

  if ! command -v shorebird &> /dev/null; then
    echo -e "${RED}Error: shorebird command not found${NC}"
    echo "Install Shorebird: https://docs.shorebird.dev"
    return 1
  fi

  if [[ -z "$email" ]]; then
    # Try to get email from current account
    local current_id=$(get_current_app_id)
    for account in $(list_all_accounts); do
      account_info=$(get_account_by_name "$account")
      if [[ -n "$account_info" ]]; then
        app_id="${account_info%:*}"
        email_candidate="${account_info#*:}"
        if [[ "$app_id" == "$current_id" ]]; then
          email="$email_candidate"
          break
        fi
      fi
    done
  fi

  if [[ -z "$email" ]]; then
    echo -e "${YELLOW}Usage: $(basename "$0") login [email]${NC}"
    echo -e "${BLUE}Or set current account first:${NC}"
    echo "  $(basename "$0") switch learnflutter"
    echo "  $(basename "$0") login"
    return 1
  fi

  echo -e "${BLUE}Logging in to Shorebird${NC}"
  echo "Email: $email"
  echo -e "\n${YELLOW}Opening browser for authentication...${NC}\n"

  shorebird login --email "$email"

  if [[ $? -eq 0 ]]; then
    echo -e "\n${GREEN}✓ Successfully logged in as $email${NC}"
    echo -e "${BLUE}Current account info:${NC}"
    show_current
  else
    echo -e "${RED}✗ Login failed${NC}"
    return 1
  fi
}

# Function: Logout
logout_shorebird() {
  echo -e "${YELLOW}Logging out from Shorebird...${NC}"
  if command -v shorebird &> /dev/null; then
    shorebird logout
    echo -e "${GREEN}✓ Logged out${NC}"
  else
    echo -e "${RED}Error: shorebird command not found${NC}"
    echo "Install Shorebird: https://docs.shorebird.dev"
    return 1
  fi
}

# Main logic
case "${1:-help}" in
  list)
    list_accounts
    ;;
  current)
    show_current
    ;;
  switch)
    if [[ -z "$2" ]]; then
      interactive_switch
    else
      switch_account "$2"
    fi
    ;;
  login)
    login_shorebird "$2"
    ;;
  logout)
    logout_shorebird
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    echo -e "${RED}Unknown command: $1${NC}\n"
    usage
    exit 1
    ;;
esac
