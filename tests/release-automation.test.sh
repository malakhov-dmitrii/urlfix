#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

source_repo="$workdir/urlfix"
tap_repo="$workdir/homebrew-urlfix"
mkdir -p "$source_repo/Formula" "$tap_repo/Formula"
source_repo="$(cd "$source_repo" && pwd -P)"
tap_repo="$(cd "$tap_repo" && pwd -P)"

cp "$repo_root/urlfix" "$source_repo/urlfix"
cp "$repo_root/README.md" "$source_repo/README.md"
cp "$repo_root/LICENSE" "$source_repo/LICENSE"

version='v9.9.9'
output="$(python3 "$repo_root/scripts/prepare-release.py" --repo "$source_repo" --tap-repo "$tap_repo" --version "$version")"

echo "$output" | grep -q "sha256="
echo "$output" | grep -q "tarball=$source_repo/dist/urlfix-$version.tar.gz"

source_formula="$source_repo/Formula/urlfix.rb"
tap_formula="$tap_repo/Formula/urlfix.rb"
[[ -f "$source_formula" ]]
[[ -f "$tap_formula" ]]

expected_url="https://github.com/malakhov-dmitrii/urlfix/releases/download/$version/urlfix-$version.tar.gz"
grep -q "$expected_url" "$source_formula"
grep -q "$expected_url" "$tap_formula"

sha="$(shasum -a 256 "$source_repo/dist/urlfix-$version.tar.gz" | awk '{print $1}')"
grep -q "$sha" "$source_formula"
grep -q "$sha" "$tap_formula"

printf 'release automation tests passed\n'
