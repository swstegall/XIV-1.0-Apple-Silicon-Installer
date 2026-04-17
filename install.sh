#!/usr/bin/env bash
# Install Final Fantasy XIV 1.0 to a local Wine prefix on Apple Silicon macOS.
#
# Prereq: the FFXIV 1.0 install disc (or its ISO) is mounted under /Volumes/
# and contains ffxivsetup.exe. The installer GUI will launch — you click
# through it manually. Everything else is automated.
#
# Re-running is safe; downloads and the Wine prefix are reused if present.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HERE/target"
RUNTIME="$TARGET/runtime"
PREFIX="$TARGET/prefix"
STAGE="$TARGET/iso/disc1"
ENV_SCRIPT="$TARGET/wine-env.sh"

WRAPPER_VERSION="1.0.11"
WRAPPER_URL="https://github.com/Sikarugir-App/Wrapper/releases/download/v1.0/Template-${WRAPPER_VERSION}.tar.xz"
ENGINE_NAME="WS12WineCX24.0.7_7"
ENGINE_URL="https://github.com/Sikarugir-App/Engines/releases/download/v1.0/${ENGINE_NAME}.tar.xz"

SE_DIR_REL="drive_c/Program Files (x86)/SquareEnix/FINAL FANTASY XIV"

log()  { printf '\n\033[1;36m[%s]\033[0m %s\n' "$(date +%H:%M:%S)" "$*"; }
die()  { printf '\n\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

# ---------- 1. Host prerequisites ----------
log "Checking host prerequisites"
[[ "$(uname -s)" == "Darwin" ]] || die "macOS only."
if ! /usr/bin/arch -x86_64 /usr/bin/true 2>/dev/null; then
    log "Installing Rosetta 2 (required for the x86_64 Wine engine)"
    softwareupdate --install-rosetta --agree-to-license
fi

# ---------- 2. Locate the mounted FFXIV installer disc ----------
log "Locating the FFXIV installer disc"
ISO_ROOT=""
for vol in /Volumes/*/; do
    if [[ -f "${vol}ffxivsetup.exe" ]]; then
        ISO_ROOT="${vol%/}"
        break
    fi
done
[[ -n "$ISO_ROOT" ]] || die "No mounted volume under /Volumes/ contains ffxivsetup.exe. Mount the FFXIV 1.0 ISO and retry."
log "Found installer at: $ISO_ROOT"

# ---------- 3. Lay down the target directory ----------
mkdir -p "$TARGET" "$RUNTIME"

# ---------- 4. Fetch the Sikarugir wrapper template (for bundled dylibs) ----------
if [[ ! -d "$RUNTIME/Frameworks" ]]; then
    log "Fetching Sikarugir wrapper template for bundled Frameworks (libinotify, MoltenVK, …)"
    tmp="$(mktemp -d)"
    curl -L --fail --retry 3 -o "$tmp/wrapper.tar.xz" "$WRAPPER_URL"
    tar -xJf "$tmp/wrapper.tar.xz" -C "$tmp"
    cp -R "$tmp/Template-${WRAPPER_VERSION}.app/Contents/Frameworks" "$RUNTIME/Frameworks"
    rm -rf "$tmp"
else
    log "Frameworks already present — skipping download"
fi

# ---------- 5. Fetch the Wine CrossOver engine (wswine.bundle) ----------
if [[ ! -x "$RUNTIME/wswine.bundle/bin/wine" ]]; then
    log "Fetching Wine engine ($ENGINE_NAME)"
    tmp="$(mktemp -d)"
    curl -L --fail --retry 3 -o "$tmp/engine.tar.xz" "$ENGINE_URL"
    tar -xJf "$tmp/engine.tar.xz" -C "$tmp"
    rm -rf "$RUNTIME/wswine.bundle"
    mv "$tmp/wswine.bundle" "$RUNTIME/wswine.bundle"
    rm -rf "$tmp"
else
    log "Wine engine already installed — skipping download"
fi

# ---------- 6. Write the environment helper script ----------
log "Writing $ENV_SCRIPT"
cat > "$ENV_SCRIPT" <<'EOF'
# Source this to use the local Wine: `source target/wine-env.sh`
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export WINEPREFIX="$HERE/prefix"
export WSBUNDLE="$HERE/runtime/wswine.bundle"
export DYLD_FALLBACK_LIBRARY_PATH="$HERE/runtime/Frameworks:$WSBUNDLE/lib:/usr/local/lib:/usr/lib"
export PATH="$WSBUNDLE/bin:$PATH"
export WINE="$WSBUNDLE/bin/wine"
export WINESERVER="$WSBUNDLE/bin/wineserver"
export WINEDEBUG="${WINEDEBUG:-fixme-all,err-all}"
EOF

# shellcheck disable=SC1090
source "$ENV_SCRIPT"
"$WINE" --version >/dev/null || die "Wine engine failed to execute. Rosetta 2 probably isn't active."

# ---------- 7. Initialize the Wine prefix ----------
if [[ ! -f "$PREFIX/system.reg" ]]; then
    log "Bootstrapping Wine prefix at $PREFIX"
    "$WINE" wineboot --init
else
    log "Wine prefix already initialized — skipping wineboot"
fi

# ---------- 8. Stage the ISO locally (read-write, survives disc eject) ----------
if [[ ! -f "$STAGE/ffxivsetup.exe" ]]; then
    log "Staging ISO contents to $STAGE"
    mkdir -p "$STAGE"
    cp -R "$ISO_ROOT/." "$STAGE/"
    chmod -R u+w "$STAGE"
else
    log "ISO already staged at $STAGE — skipping copy"
fi

# ---------- 9. Run the installer (requires manual click-through) ----------
INSTALL_DIR="$PREFIX/$SE_DIR_REL"
if [[ -f "$INSTALL_DIR/ffxivboot.exe" ]]; then
    log "FFXIV already installed at $INSTALL_DIR — skipping installer"
else
    log "Launching ffxivsetup.exe — drive the InstallShield GUI manually."
    log "Leave the default install path (C:\\Program Files (x86)\\SquareEnix\\FINAL FANTASY XIV)."
    ( cd "$STAGE" && "$WINE" ffxivsetup.exe )
    log "Installer exited. Giving wineserver a moment to flush…"
    "$WINESERVER" -w || true
fi

# ---------- 10. Post-install verification ----------
log "Verifying install"
fail=0
for exe in ffxivboot.exe ffxivupdater.exe ffxivconfig.exe; do
    if [[ -f "$INSTALL_DIR/$exe" ]]; then
        printf '  ✓ %s\n' "$exe"
    else
        printf '  ✗ %s (missing)\n' "$exe"
        fail=1
    fi
done

data_count=$(find "$INSTALL_DIR/data" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
client_count=$(find "$INSTALL_DIR/client" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
printf '  data/   subdirs: %s\n' "$data_count"
printf '  client/ subdirs: %s\n' "$client_count"
[[ "$data_count"   -ge 50 ]] || { printf '    (expected ~80+ data archives)\n'; fail=1; }
[[ "$client_count" -ge  3 ]] || { printf '    (expected chara, cut, script, sqwt, vfx)\n'; fail=1; }

install_size=$(du -sh "$INSTALL_DIR" 2>/dev/null | awk '{print $1}')
printf '  total size: %s\n' "$install_size"

if [[ "$fail" -eq 0 ]]; then
    log "Install verified."
    cat <<EOF

Re-enter the environment later with:
  cd $TARGET && source ./wine-env.sh
  "\$WINE" "\$WINEPREFIX/$SE_DIR_REL/ffxivboot.exe"
EOF
else
    die "Verification failed — check the installer output above."
fi
