# XIV 1.0 Apple Silicon Installer

A bash installer that sets up **Final Fantasy XIV 1.0** in a self-contained Wine prefix on Apple Silicon Macs. The installer pulls the [Sikarugir](https://github.com/Sikarugir-App) wrapper Frameworks and a CrossOver-based Wine engine, bootstraps a prefix, and runs the original `ffxivsetup.exe` from the retail install disc.

Everything lives under `./target/` next to the script — no system-wide changes, no Homebrew, no admin install paths.

## Requirements

- Apple Silicon Mac running macOS (Darwin).
- Rosetta 2 (the script installs it automatically if missing — the bundled Wine engine is x86_64).
- The **FFXIV 1.0** install disc or its ISO mounted under `/Volumes/`. The mount must contain `ffxivsetup.exe` at its root.
- Internet access for the first run (wrapper template + Wine engine downloads).

## Usage

```sh
./install.sh
```

The script will:

1. Verify it's running on macOS and install Rosetta 2 if needed.
2. Locate the mounted FFXIV install volume by scanning `/Volumes/*/` for `ffxivsetup.exe`.
3. Download the Sikarugir wrapper template (for bundled `Frameworks/` — libinotify, MoltenVK, etc.) into `target/runtime/Frameworks/`.
4. Download the Wine engine (`WS12WineCX24.0.7_7`) into `target/runtime/wswine.bundle/`.
5. Write `target/wine-env.sh`, a sourceable env file that wires `WINE`, `WINEPREFIX`, `DYLD_FALLBACK_LIBRARY_PATH`, and `PATH` to the local runtime.
6. Bootstrap a Wine prefix at `target/prefix/` via `wineboot --init`.
7. Stage the ISO contents to `target/iso/disc1/` so the install survives ejecting the disc.
8. Launch `ffxivsetup.exe` — **you click through the InstallShield GUI manually**. Leave the default install path (`C:\Program Files (x86)\SquareEnix\FINAL FANTASY XIV`).
9. Verify the install by checking for `ffxivboot.exe`, `ffxivupdater.exe`, `ffxivconfig.exe`, and the expected `data/` and `client/` subdirectory counts.

Re-running the script is safe. Each step skips itself if its output already exists, so you can resume after a failure or repeat verification without re-downloading anything.

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

## Launching the game after install

```sh
cd target
source ./wine-env.sh
"$WINE" "$WINEPREFIX/drive_c/Program Files (x86)/SquareEnix/FINAL FANTASY XIV/ffxivboot.exe"
```

## Troubleshooting

- **"No mounted volume under /Volumes/ contains ffxivsetup.exe"** — the ISO isn't mounted, or you mounted a disc that isn't the 1.0 client. Mount it (double-click the `.iso` in Finder) and re-run.
- **"Wine engine failed to execute"** — Rosetta 2 isn't active. Run `softwareupdate --install-rosetta --agree-to-license` and retry.
- **Verification fails with too few `data/` or `client/` subdirs** — the InstallShield GUI was cancelled or pointed at a non-default path. Delete `target/prefix/drive_c/Program Files (x86)/SquareEnix/` and re-run.

## Credits

- Wrapper Frameworks and Wine engine are built and distributed by the [Sikarugir-App](https://github.com/Sikarugir-App) project.
