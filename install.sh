#!/usr/bin/env bash
# =============================================================================
# hazsync installer — macOS, Linux, and Windows (via WSL)
# =============================================================================
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/USER/hazsync/main/install.sh | bash
#
# Or, from a cloned checkout:
#   ./install.sh
#
# Installs the `hazsync` script to ~/.local/bin (override with PREFIX=...),
# then checks for the runtime dependencies (rsync, ssh, python3).
# =============================================================================
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/USER/hazsync/main"
PREFIX="${PREFIX:-$HOME/.local/bin}"
DEST="$PREFIX/hazsync"

say()  { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }

# --- locate the script: prefer a local checkout, else download ----------------
src=""
if [[ -f "$(dirname "$0")/bin/hazsync" ]]; then
    src="$(dirname "$0")/bin/hazsync"
fi

mkdir -p "$PREFIX"
if [[ -n "$src" ]]; then
    say "installing from local checkout: $src"
    install -m 0755 "$src" "$DEST"
else
    say "downloading hazsync from $REPO_RAW/bin/hazsync"
    curl -fsSL "$REPO_RAW/bin/hazsync" -o "$DEST"
    chmod 0755 "$DEST"
fi
say "installed: $DEST"

# --- PATH check ---------------------------------------------------------------
case ":$PATH:" in
    *":$PREFIX:"*) : ;;
    *) warn "$PREFIX is not on your PATH. Add this to your shell profile:"
       say  "       export PATH=\"$PREFIX:\$PATH\"" ;;
esac

# --- dependency check ---------------------------------------------------------
missing=()
for dep in rsync ssh python3; do
    command -v "$dep" >/dev/null 2>&1 || missing+=("$dep")
done
if [[ ${#missing[@]} -gt 0 ]]; then
    warn "missing dependencies: ${missing[*]}"
    say  "  macOS : brew install ${missing[*]}"
    say  "  Debian/Ubuntu/WSL : sudo apt install ${missing[*]}"
fi

say ""
say "next steps:"
say "  hazsync config-init      # scaffold ~/.config/hazsync/hazsync.toml, then edit it"
say "  cd <your-project> && hazsync init"
say "  hazsync --version"
