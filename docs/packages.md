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

## Google Chrome updates

The package script installs Chrome through Homebrew when missing. Once Homebrew
tracks Chrome and its app exists in `/Applications` or `~/Applications`, package
sync skips Chrome using `HOMEBREW_BUNDLE_CASK_SKIP` for that bundle command only.
Chrome's built-in updater then maintains it. Keep automatic Chrome updates enabled;
you can check them in Chrome's **About Google Chrome** page.

This avoids Homebrew replacing Chrome app files owned by its updater, which can
require sudo and leave a conflicting backup in Caskroom after a failed upgrade.
Existing Caskroom leftovers can remain without blocking package sync. Chrome stays
declared in the Brewfile so bundle cleanup retains it. Other packages still upgrade
normally, and existing skip settings are preserved. Explicit `brew upgrade --cask
google-chrome` commands remain outside this policy and can still need manual repair.

## Local Homebrew casks

Custom casks live in `Casks/` in this dotfiles repository. On macOS, the package
script creates a non-Git tap at
`$(brew --repository)/Library/Taps/local/homebrew-dotfiles` and links its `Casks`
directory to the chezmoi source directory. The tap is declared as `local/dotfiles`
in `packages.yaml`; casks use fully qualified names such as
`local/dotfiles/pocket-ai`. The existing tap setup trusts this local tap.

Run `chezmoi apply` to register the tap and install declared packages. Once the
tap is registered, a single cask can also be installed with
`brew install --cask local/dotfiles/pocket-ai`. Editing a local cask changes the
package script's content hash, so the next apply reruns package synchronization.
`Casks/` is ignored as a home-directory target and remains in the source repository.

Pocket uses the [official desktop beta](https://docs.heypocketai.com/docs/getting-started/download-app),
which supports Intel and Apple Silicon Macs running macOS 13 or later. Its
unversioned download URL serves the current release, so the cask uses
`version :latest` and `sha256 :no_check`. To explicitly refresh an installed copy,
run `brew reinstall --cask local/dotfiles/pocket-ai`. This desktop app replaces
the unsupported iPhone App Store entry in the package list.
