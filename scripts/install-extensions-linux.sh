#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXTENSIONS_FILE="${1:-$ROOT_DIR/extensions/extensions.txt}"
FAILED_FILE="${FAILED_FILE:-$ROOT_DIR/extensions/failed-linux.txt}"
CODE_BIN="${CODE_BIN:-code}"
RETRIES="${RETRIES:-2}"

if ! command -v "$CODE_BIN" >/dev/null 2>&1; then
    echo "VS Code CLI '$CODE_BIN' is not available in PATH."
    echo "Open VS Code, run 'Shell Command: Install code command in PATH', then restart the terminal."
    exit 1
fi

if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "Extensions file not found: $EXTENSIONS_FILE"
    echo "Run from the repo root or pass a path to extensions.txt:"
    echo "  bash scripts/install-extensions-linux.sh /path/to/extensions.txt"
    exit 1
fi

: > "$FAILED_FILE"

total=0
installed=0
failed=0

while IFS= read -r extension || [ -n "$extension" ]; do
    extension="${extension%%#*}"
    extension="$(printf '%s' "$extension" | xargs)"

    if [ -z "$extension" ]; then
        continue
    fi

    total=$((total + 1))
    echo
    echo "[$total] Installing $extension"

    ok=0
    attempt=1
    while [ "$attempt" -le "$RETRIES" ]; do
        if "$CODE_BIN" --install-extension "$extension"; then
            ok=1
            installed=$((installed + 1))
            break
        fi

        echo "Attempt $attempt failed for $extension"
        attempt=$((attempt + 1))
        sleep 2
    done

    if [ "$ok" -ne 1 ]; then
        failed=$((failed + 1))
        echo "$extension" >> "$FAILED_FILE"
        echo "Skipped $extension"
    fi
done < "$EXTENSIONS_FILE"

echo
echo "Done."
echo "Processed: $total"
echo "Installed or already present: $installed"
echo "Failed and skipped: $failed"

if [ "$failed" -gt 0 ]; then
    echo "Failed list: $FAILED_FILE"
fi
