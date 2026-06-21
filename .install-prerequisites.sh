#!/bin/bash
set -ex

case "$(uname -s)" in
Darwin)
    if type op >/dev/null 2>&1; then
        echo "1Password CLI is already installed"
    else
        brew install --cask 1password
        brew install 1password-cli git wget gnupg gh jq dockutil
    fi

    read -p "Please open 1Password, log into all accounts and set under Settings>CLI activate Integrate with 1Password CLI. Press any key to continue." -n 1 -r
    echo
    ;;
Linux)
    echo "Linux detected — skipping 1Password and Homebrew"
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac