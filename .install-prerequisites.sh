#!/bin/bash
set -euo pipefail

# This runs in chezmoi's read-source-state.pre hook, i.e. on *every* chezmoi
# invocation, because templates read secrets from 1Password during source-state
# evaluation. So `op` must exist and the desktop CLI integration must be active
# before chezmoi reads source state.
#
# Installing prerequisites is idempotent and stays quiet on repeat runs. The
# interactive "open 1Password and log in" prompt is gated behind a marker file
# so it appears only the first time on a given machine and never again.

state_dir="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi"
op_configured_marker="$state_dir/.1password-cli-configured"

case "$(uname -s)" in
Darwin)
    echo "OS: MacOS"
    # Install any missing prerequisites. brew is a no-op for already-installed
    # formulae/casks, so this is safe to run every time.
    if ! type op >/dev/null 2>&1; then
        brew install --cask 1password
        brew install 1password-cli git wget gnupg gh jq dockutil
    fi

    echo "1Password CLI version: $(op --version)"

    # Prompt to enable the 1Password CLI integration exactly once.
    if [ ! -f "$op_configured_marker" ]; then
        msg="Open 1Password, log into all accounts, and under Settings > Developer enable 'Integrate with 1Password CLI'."
        if [ -t 0 ]; then
            read -p "$msg Press any key once done." -n 1 -r
            echo
        else
            echo "NOTE: $msg"
        fi
        mkdir -p "$state_dir"
        touch "$op_configured_marker"
    fi
    ;;
Linux)
    echo "OS: Linux"
    # Only run the (privileged, network-touching) install once. This hook fires
    # on every chezmoi invocation, so guard on `op` already being present —
    # otherwise every run triggers a sudo password prompt and an apt update.
    if ! type op >/dev/null 2>&1; then
        curl -sS https://downloads.1password.com/linux/keys/1password.asc \
            | sudo gpg --dearmor --batch --yes \
            --output /usr/share/keyrings/1password-archive-keyring.gpg

        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" \
            | sudo tee /etc/apt/sources.list.d/1password.list >/dev/null

        sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
        curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol \
            | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol >/dev/null

        sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
        curl -sS https://downloads.1password.com/linux/keys/1password.asc \
            | sudo gpg --dearmor --batch --yes \
            --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

        sudo apt update && sudo apt install -y 1password-cli git wget gnupg gh jq
    fi

    echo "1Password CLI version: $(op --version)"

    # Prompt to enable the 1Password CLI integration exactly once.
    if [ ! -f "$op_configured_marker" ]; then
        msg="Open 1Password, log into all accounts, and under Settings > Developer enable 'Integrate with 1Password CLI'."
        if [ -t 0 ]; then
            read -p "$msg Press any key once done." -n 1 -r
            echo
        else
            echo "NOTE: $msg"
        fi
        mkdir -p "$state_dir"
        touch "$op_configured_marker"
    fi
    ;;
*)
    echo "OS: Unsupported - $(uname -s)"
    exit 1
    ;;
esac
