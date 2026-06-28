#!/usr/bin/env bash

set -ex

# This script installs everything from scratch. It is meant to be used through a curl to bash command.

# Prompt for sudo up front so the privileged steps further down don't block
# waiting for a password mid-run.
sudo -v

case "$OSTYPE" in
    linux*)
        echo "Running on Linux"
        if [ -f /etc/os-release ]; then
            # Load the OS distribution variables
            source /etc/os-release

            case "$ID" in
                ubuntu)
                    echo "Distribution: Ubuntu"
                    sudo apt update
                    # chezmoi is not in the Ubuntu apt repositories; use the
                    # official installer, which drops the binary in ~/.local/bin.
                    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
                    export PATH="$HOME/.local/bin:$PATH"
                    ;;

                *)
                    echo "Distribution: $NAME ($ID)"
                    echo "Not a supported Linux distribution."
                    exit 1
                    ;;
            esac
        else
            echo "Not a standard Linux distribution (missing /etc/os-release)"
            exit 1
        fi
        ;;

    darwin*)
        echo "Running on macOS"
        # Install XCode Command Line Tools if necessary
        xcode-select --install || echo "XCode already installed"

        # Install Homebrew if necessary
        if which -s brew; then
            echo 'Homebrew is already installed'
        else
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            (
                echo
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
            ) >>$HOME/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        brew install chezmoi
        ;;
    *)
        echo "Unknown Operating System: $OSTYPE"
        exit 1
        ;;
esac


chezmoi init aechrok
chezmoi apply
