#!/bin/bash
set -eu

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
    # Install any missing prerequisites. brew is a no-op for already-installed
    # formulae/casks, so this is safe to run every time.
    if ! type op >/dev/null 2>&1; then
        brew install --cask 1password
        brew install 1password-cli git wget gnupg gh jq dockutil
    fi

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
    echo "Linux detected — skipping 1Password and Homebrew"
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac
