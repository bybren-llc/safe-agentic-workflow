#!/usr/bin/env bash
# test-validator-gates.sh — prove the vault validator's gates actually enforce.
#
# A gate that only ever passes is not a gate. Each case below deliberately breaks one rule
# and asserts the validator reports it. The final case asserts the shipped starter bundle
# is clean, and that it survives being copied (the flow the quickstart tells adopters to run).
#
# Usage: bash knowledge-vault/tests/test-validator-gates.sh
# Exit:  0 all assertions passed, 1 otherwise

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
VALIDATOR="$ROOT/knowledge-vault/scripts/validate-vault.mjs"
BUNDLE="$ROOT/knowledge-vault/templates/starter-bundle"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

GREEN='\033[0;32m'; RED='\033[0;31m'; DIM='\033[0;36m'; NC='\033[0m'
pass=0; fail=0

reset_fixture() {
  rm -rf "$WORK/vault"
  cp -r "$BUNDLE" "$WORK/vault"
}

# assert_error <pattern> <description>
assert_error() {
  local pattern="$1" desc="$2" out
  out="$(node "$VALIDATOR" --vault "$WORK/vault" 2>&1)"
  if grep -q "$pattern" <<<"$out"; then
    echo -e "  ${GREEN}PASS${NC} $desc"
    pass=$((pass + 1))
  else
    echo -e "  ${RED}FAIL${NC} $desc — expected an error matching: $pattern"
    echo "$out" | sed 's/^/        /'
    fail=$((fail + 1))
  fi
}

# assert_clean <dir> <description>
assert_clean() {
  local dir="$1" desc="$2" out
  if out="$(node "$VALIDATOR" --vault "$dir" 2>&1)"; then
    echo -e "  ${GREEN}PASS${NC} $desc"
    pass=$((pass + 1))
  else
    echo -e "  ${RED}FAIL${NC} $desc — expected exit 0"
    echo "$out" | sed 's/^/        /'
    fail=$((fail + 1))
  fi
}

echo -e "${DIM}--- The shipped bundle is clean ---${NC}"
assert_clean "$BUNDLE" "starter bundle validates with zero errors"

echo -e "${DIM}--- Gate: wikilinks are rejected ---${NC}"
reset_fixture
printf '\n[[some-concept]]\n' >>"$WORK/vault/process/vault-maintenance.md"
assert_error "wikilink" "a wikilink is an error"

echo -e "${DIM}--- Gate: repo-host URLs for repo files are rejected ---${NC}"
reset_fixture
python3 - "$WORK/vault/process/vault-maintenance.md" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read().replace(
    "## Citations",
    "## Citations\n\n- [x](https://github.com/org/repo/blob/main/x.ts) — repo file by URL", 1)
open(p, "w").write(s)
PY
assert_error "repo-host URL" "a repo-host URL to a repo file is an error"

echo -e "${DIM}--- Gate: frontmatter paths must exist ---${NC}"
reset_fixture
python3 - "$WORK/vault/process/vault-maintenance.md" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read().replace("domain: platform", 'domain: platform\nresource: "does/not/exist.ts"')
open(p, "w").write(s)
PY
assert_error "path does not exist" "a resource pointing at a missing file is an error"

echo -e "${DIM}--- Gate: stub types must cite their source of truth ---${NC}"
reset_fixture
cat >"$WORK/vault/orphan-pattern.md" <<'MD'
---
type: pattern
title: "Example Pattern"
description: "A stub concept that fails to cite any source of truth."
resource: "knowledge-vault/README.md"
tags: [process]
timestamp: 2026-07-19
status: active
---

# Example Pattern

## Overview

Body.

## Exemplars

None.

## Citations

- [Conventions](_meta/CONVENTIONS.md)
MD
assert_error "is a stub" "a stub type with no out-of-bundle citation is an error"

echo -e "${DIM}--- Gate: canvas nodes must reference real files ---${NC}"
reset_fixture
python3 - "$WORK/vault/maps/system-overview.canvas" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read().replace("starter-bundle/start-here.md", "starter-bundle/ghost.md")
open(p, "w").write(s)
PY
assert_error "canvas node references missing" "a dangling canvas node is an error"

echo -e "${DIM}--- Gate: every concept must be in the manifest registry ---${NC}"
reset_fixture
python3 - "$WORK/vault/_meta/manifest.json" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read().replace('"id": "start-here",', '"id": "start-here-renamed",')
open(p, "w").write(s)
PY
assert_error "not in manifest" "a concept missing from the ID registry is an error"

echo -e "${DIM}--- Gate: section structure must match the type template ---${NC}"
reset_fixture
python3 - "$WORK/vault/process/vault-maintenance.md" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read().replace("## Roles Involved", "## Who Does It")
open(p, "w").write(s)
PY
assert_error "!= template" "a renamed section is an error"

echo -e "${DIM}--- The bundle survives being copied (quickstart flow) ---${NC}"
rm -rf "$WORK/moved"
cp -r "$BUNDLE" "$WORK/moved"
sed -i.bak 's|"starter-bundle/|"moved/|g' "$WORK/moved"/maps/*.canvas && rm -f "$WORK/moved"/maps/*.bak
python3 - "$WORK/moved/_meta/vault-config.json" "$WORK/moved" <<'PY'
import sys
p, newroot = sys.argv[1], sys.argv[2]
s = open(p).read().replace(
    '"bundle_root": "knowledge-vault/templates/starter-bundle"',
    '"bundle_root": "%s"' % newroot)
open(p, "w").write(s)
PY
assert_clean "$WORK/moved" "copied bundle validates clean after the documented rewrite"

echo
if [ "$fail" -eq 0 ]; then
  echo -e "${GREEN}All $pass assertions passed.${NC}"
  exit 0
fi
echo -e "${RED}$fail failed, $pass passed.${NC}"
exit 1
