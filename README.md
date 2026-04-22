# XIV 1.0 Apple Silicon Installer

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.md)
[![Platform: macOS (Apple Silicon)](https://img.shields.io/badge/platform-macOS%20(Apple%20Silicon)-lightgrey.svg)](#requirements)
[![Discord](https://img.shields.io/badge/discord-join-5865F2.svg)](https://discord.gg/CVjwWs6jnX)

A single-command installer that brings the original **FINAL FANTASY XIV
1.0** — the 2010 release, not *A Realm Reborn* — up on an Apple Silicon
Mac. Given the retail install disc or its ISO, `install.sh` handles
every step through to a playable `ffxivboot.exe`.

Under the hood it downloads the
[Sikarugir](https://github.com/Sikarugir-App) wrapper Frameworks and a
CrossOver-built Wine engine, provisions a dedicated Wine prefix, and
drives the stock `ffxivsetup.exe` through to completion. Everything it
produces lives inside `./target/` next to the script — no Homebrew, no
`/usr/local`, and no admin rights required.

This repository ships the installer and its documentation. It does
**not** redistribute the FFXIV 1.0 client; you must supply your own
retail disc or ISO.

> Created with [Claude](https://claude.ai/).

## Features

- **One idempotent script.** Re-running skips any step whose output
  already exists, so failed runs can be resumed without cleanup.
- **Self-contained runtime.** Sikarugir Frameworks and the CrossOver
  Wine engine install under `target/runtime/`. Removing the repository
  removes the install.
- **Rosetta 2 auto-install.** The bundled Wine engine is x86_64; the
  script invokes `softwareupdate` on your behalf if Rosetta is absent.
- **Automatic disc discovery.** Scans `/Volumes/*/` for
  `ffxivsetup.exe` — no path arguments to pass.
- **Local ISO staging.** Copies disc contents into `target/iso/disc1/`
  before launching the installer, so the install survives ejecting the
  original medium.
- **Post-install verification.** Confirms `ffxivboot.exe`,
  `ffxivupdater.exe`, `ffxivconfig.exe`, and the expected `data/` /
  `client/` archive layout before declaring success.

## Requirements

- Apple Silicon Mac running macOS.
- **FINAL FANTASY XIV 1.0** install disc, or its ISO mounted under
  `/Volumes/`, with `ffxivsetup.exe` at the root.
- Rosetta 2 — installed automatically by the script if missing.
- Internet access on first run for the wrapper template and Wine engine
  downloads.

## Installation

```sh
./install.sh
```

The script runs unattended until the InstallShield GUI appears, at
which point it hands control to you for the manual click-through.
Accept all defaults; in particular, leave the install path at
`C:\Program Files (x86)\SquareEnix\FINAL FANTASY XIV` so the
verification step can find the expected file layout.

## Launching the game

After `install.sh` reports "Install verified.":

```sh
cd target
source ./wine-env.sh
"$WINE" "$WINEPREFIX/drive_c/Program Files (x86)/SquareEnix/FINAL FANTASY XIV/ffxivboot.exe"
```

`wine-env.sh` exports `WINEPREFIX`, `WINE`, `WINESERVER`, and the
library paths the bundled engine expects. Source it from any shell
session before invoking Wine directly.

## Repository layout

After a successful install, the layout of `target/` is:

```
target/
├── runtime/
│   ├── Frameworks/      bundled dylibs from the Sikarugir wrapper
│   └── wswine.bundle/   CrossOver Wine engine (bin/, lib/, share/)
├── prefix/              WINEPREFIX — the Wine C: drive
├── iso/disc1/           local copy of the install disc contents
└── wine-env.sh          source to activate the local Wine
```

## Troubleshooting

| Symptom | Likely cause and resolution |
| --- | --- |
| `No mounted volume under /Volumes/ contains ffxivsetup.exe` | The ISO isn't mounted, or the mounted disc isn't the 1.0 client. Double-click the 1.0 `.iso` in Finder and re-run the script. |
| `Wine engine failed to execute` | Rosetta 2 is not active. Run `softwareupdate --install-rosetta --agree-to-license` and retry. |
| Verification reports too few `data/` or `client/` subdirectories | The InstallShield GUI was cancelled, or a non-default install path was chosen. Delete `target/prefix/drive_c/Program Files (x86)/SquareEnix/` and run `install.sh` again. |

## Licensing and attribution

The installer script and the documentation in this repository are
distributed under the **MIT License**. See [`LICENSE.md`](LICENSE.md)
for the full terms and a per-component breakdown of the third-party
software fetched at runtime — the Sikarugir wrapper, the CrossOver
Wine engine (Wine itself is LGPL-2.1-or-later), and the FFXIV 1.0
client (© SQUARE ENIX CO., LTD., not redistributed).

## Sister projects

- **[Garlemald Server](https://github.com/swstegall/Garlemald-Server)** —
  Rust port of Project Meteor's FFXIV 1.23b server emulator (lobby /
  world / map) that the install produced by this script can connect
  to.
- **[Garlemald Client](https://github.com/swstegall/Garlemald-Client)** —
  cross-platform Rust launcher that detects the install produced by
  this script and drives it against a private server.

## Community

Development discussion, bug reports, and direct contact with the
maintainer happen on the project Discord:

<https://discord.gg/CVjwWs6jnX>
