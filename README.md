# XIV 1.0 Apple Silicon Installer

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.md)
[![Platform](https://img.shields.io/badge/platform-macOS%20Apple%20Silicon-lightgrey.svg)](#requirements)
[![Discord](https://img.shields.io/badge/discord-join-5865F2.svg)](https://discord.gg/CVjwWs6jnX)

A self-contained bash installer for **FINAL FANTASY XIV v1.0** on
Apple Silicon Macs — the original 1.0 iteration of the game, not
*A Realm Reborn*.

The installer pulls the [Sikarugir](https://github.com/Sikarugir-App)
wrapper Frameworks and a CrossOver-based Wine engine, bootstraps a
prefix, and runs the original `ffxivsetup.exe` from the retail install
disc. Everything lives under `./target/` next to the script — no
system-wide changes, no Homebrew, no admin install paths.

> Created with [Claude](https://claude.ai/).

## Highlights

- Single bash script, idempotent — re-running skips any step whose
  output already exists
- Self-contained runtime: Sikarugir Frameworks + CrossOver Wine engine
  land under `target/runtime/`, nothing touches the system
- Auto-installs Rosetta 2 if missing (the bundled Wine engine is
  x86_64)
- Locates the FFXIV 1.0 install disc automatically by scanning
  `/Volumes/*/` for `ffxivsetup.exe`
- Stages the ISO locally so the install survives ejecting the disc
- Post-install verification of `ffxivboot.exe`, `ffxivupdater.exe`,
  `ffxivconfig.exe`, and the expected `data/` and `client/`
  subdirectory layout

## Requirements

- Apple Silicon Mac running macOS (Darwin)
- Rosetta 2 (installed automatically by the script if missing)
- The **FFXIV 1.0** install disc or its ISO mounted under `/Volumes/`
  with `ffxivsetup.exe` at its root
- Internet access on first run for the wrapper template and Wine
  engine downloads

## Usage

```sh
./install.sh
```

You click through the InstallShield GUI manually when it pops up;
leave the default install path
(`C:\Program Files (x86)\SquareEnix\FINAL FANTASY XIV`).

## Launching the game after install

```sh
cd target
source ./wine-env.sh
"$WINE" "$WINEPREFIX/drive_c/Program Files (x86)/SquareEnix/FINAL FANTASY XIV/ffxivboot.exe"
```

## Layout

```
target/
├── runtime/
│   ├── Frameworks/      # bundled dylibs from the Sikarugir wrapper
│   └── wswine.bundle/   # CrossOver Wine engine (bin/, lib/, share/)
├── prefix/              # WINEPREFIX — the C: drive lives here
├── iso/disc1/           # local copy of the install disc contents
└── wine-env.sh          # source this to use the local Wine
```

## Troubleshooting

- **"No mounted volume under /Volumes/ contains ffxivsetup.exe"** —
  the ISO isn't mounted, or you mounted a disc that isn't the 1.0
  client. Mount it (double-click the `.iso` in Finder) and re-run.
- **"Wine engine failed to execute"** — Rosetta 2 isn't active. Run
  `softwareupdate --install-rosetta --agree-to-license` and retry.
- **Verification fails with too few `data/` or `client/` subdirs** —
  the InstallShield GUI was cancelled or pointed at a non-default
  path. Delete
  `target/prefix/drive_c/Program Files (x86)/SquareEnix/` and re-run.

## Attribution and licensing

The wrapper Frameworks and Wine engine are built and distributed by
the [Sikarugir-App](https://github.com/Sikarugir-App) project and
CodeWeavers / the upstream [Wine](https://www.winehq.org/) project —
each retains its own license terms. This installer script itself is
distributed under the **MIT License**; see [`LICENSE.md`](LICENSE.md)
for the full terms and notes on the third-party components it
downloads.

## Sister projects

- **[Garlemald Server](https://github.com/swstegall/Garlemald-Server)** —
  Rust FFXIV 1.23b server (lobby / world / map) that this install
  can connect to.
- **[Garlemald Client](https://github.com/swstegall/Garlemald-Client)** —
  cross-platform Rust launcher that detects the install produced by
  this script and drives it against a private server.

## Community

Questions, bug reports, or just want to talk about the project?
Join the Discord:

<https://discord.gg/CVjwWs6jnX>
