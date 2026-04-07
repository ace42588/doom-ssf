#!/usr/bin/env bash
set -euo pipefail

# Syncs external contract artifacts from the authoritative doom-contracts repo
# into this repository using the pinned dependency declared in contract.lock.
#
# Requirements:
#   - bash
#   - git
#   - python3
#
# Optional:
#   - rsync (preferred for copying)
#
# Usage:
#   ./tooling/sync-contracts.sh
#
# Notes:
#   - This script treats doom-contracts as the source of truth.
#   - Generated/copied artifacts in external/generated-contracts must not be
#     edited manually.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCK_FILE="$ROOT_DIR/contract.lock"
OUTPUT_DIR="$ROOT_DIR/external/generated-contracts"

if [[ ! -f "$LOCK_FILE" ]]; then
  echo "error: contract.lock not found at $LOCK_FILE" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "error: python3 is required" >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "error: git is required" >&2
  exit 1
fi

read_lock_field() {
  local field="$1"
  python3 - "$LOCK_FILE" "$field" <<'PY'
import json
import sys

lock_path = sys.argv[1]
field = sys.argv[2]

with open(lock_path, "r", encoding="utf-8") as f:
    data = json.load(f)

parts = field.split(".")
value = data
for part in parts:
    value = value[part]

if isinstance(value, list):
    for item in value:
        print(item)
else:
    print(value)
PY
}

SCHEMA_VERSION="$(read_lock_field schema_version)"
REPOSITORY="$(read_lock_field dependency.repository)"
REF_TYPE="$(read_lock_field dependency.default_ref_type)"
REF_VALUE="$(read_lock_field dependency.ref)"
COMMIT_SHA="$(read_lock_field dependency.commit)"
SOURCE_SUBPATH="$(read_lock_field artifacts.source_subpath)"

if [[ "$SCHEMA_VERSION" != "1" ]]; then
  echo "error: unsupported contract.lock schema_version: $SCHEMA_VERSION" >&2
  exit 1
fi

if [[ -z "$REPOSITORY" || -z "$COMMIT_SHA" ]]; then
  echo "error: repository and commit must be set in contract.lock" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

REPO_DIR="$TMP_DIR/doom-contracts"
SRC_DIR="$REPO_DIR/$SOURCE_SUBPATH"

echo "==> Cloning doom-contracts"
git clone --no-checkout "$REPOSITORY" "$REPO_DIR" >/dev/null 2>&1

cd "$REPO_DIR"

echo "==> Fetching refs"
git fetch --tags --force origin >/dev/null 2>&1 || true
git fetch origin "$COMMIT_SHA" >/dev/null 2>&1 || true

if [[ -n "$REF_VALUE" ]]; then
  case "$REF_TYPE" in
    tag)
      git fetch origin "refs/tags/$REF_VALUE:refs/tags/$REF_VALUE" >/dev/null 2>&1 || true
      ;;
    branch)
      git fetch origin "$REF_VALUE" >/dev/null 2>&1 || true
      ;;
    *)
      echo "warning: unknown ref type '$REF_TYPE'; proceeding with commit pin only" >&2
      ;;
  esac
fi

echo "==> Checking out pinned commit"
git checkout --quiet "$COMMIT_SHA"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "error: source_subpath does not exist in checked out repo: $SRC_DIR" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "==> Clearing existing generated artifacts"
find "$OUTPUT_DIR" -mindepth 1 -maxdepth 1 ! -name README.md -exec rm -rf {} +

copy_path_if_present() {
  local rel="$1"
  local from="$SRC_DIR/$rel"
  local to="$OUTPUT_DIR/$rel"

  if [[ -e "$from" ]]; then
    mkdir -p "$(dirname "$to")"
    if command -v rsync >/dev/null 2>&1; then
      rsync -a "$from" "$to"
    else
      cp -R "$from" "$to"
    fi
    echo "  copied: $rel"
  else
    echo "  skipped: $rel (not present)"
  fi
}

echo "==> Copying selected artifact roots"
copy_path_if_present "schemas"
copy_path_if_present "openapi"
copy_path_if_present "jsonschema"
copy_path_if_present "examples"

cat > "$OUTPUT_DIR/README.md" <<EOF
# Generated Contracts

This directory contains artifacts copied from the authoritative
\`doom-contracts\` repository.

Do not edit files here manually.

Source repository:
- $REPOSITORY

Pinned ref:
- $REF_TYPE: $REF_VALUE

Pinned commit:
- $COMMIT_SHA

To refresh:
\`\`\`bash
./tooling/sync-contracts.sh
\`\`\`
EOF

echo "==> Sync complete"
echo
echo "Updated output:"
echo "  $OUTPUT_DIR"
echo
echo "Pinned source:"
echo "  repository: $REPOSITORY"
echo "  ref:        $REF_TYPE:$REF_VALUE"
echo "  commit:     $COMMIT_SHA"