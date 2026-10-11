# My dotfiles

> managed by [chezmoi](https://www.chezmoi.io/)

## Setup

```bash
curl -sfL https://raw.githubusercontent.com/aechrok/dotfiles/main/.startup.sh | bash
```

## Management

All packages to be installed should be listed in `.chezmoidata/packages.yaml`. This includes brew, taps, krew, mac app store, and apt packages.

Homebrew formulae and taps accept plain strings or single-key maps with optional
requirements. Empty maps (`- "bash": {}`) and empty or omitted requirements impose
no restrictions. All supplied requirements must match:

```yaml
brews:
  - "bash"
  - "omlx":
      requirements:
        os: darwin
        memory: 128
```

`os` uses chezmoi OS names (`darwin` for macOS, `linux` for Linux). `memory` is
the minimum RAM in GiB, using `machine.memoryGb` captured by `chezmoi init`.
Entries remain scoped to their universal, work, or private section. Use matching
requirements on a package's tap when it should also be conditional. Audit and
cleanup use the same requirements as installation; ineligible packages can be
removed by cleanup. Unknown requirement names cause an error.

## Git signing

Git uses the 1Password SSH signer on macOS. The managed
`~/.config/1Password/ssh/agent.toml` exposes SSH Key items only from Employee on
work computers and from Dotfiles and Personal on personal computers, based on
`isWorkComputer`. This replaces 1Password's default vault selection.
The matching private signing key must be stored as an SSH Key item in 1Password;
downloading a key file or importing a GPG key does not make it available to this
signer.

Apply the agent config with:

```bash
chezmoi apply ~/.config/1Password/ssh/agent.toml
```

Then lock and unlock 1Password so it recognizes the configuration. Enable the
SSH agent in 1Password's Developer settings if it is not already enabled.
