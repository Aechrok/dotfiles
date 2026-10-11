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