#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/release.sh v0.1.2 [path/to/homebrew-urlfix]

What it does:
  1. runs ./tests/urlfix.test.sh
  2. builds a deterministic dist/urlfix-<version>.tar.gz asset
  3. updates Formula/urlfix.rb in the source repo
  4. optionally updates Formula/urlfix.rb in the tap repo
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" || $# -lt 1 ]]; then
  usage
  exit $([[ $# -lt 1 ]] && echo 1 || echo 0)
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$1"
tap_repo="${2:-}"

"$repo_root/tests/urlfix.test.sh"

cmd=(python3 "$repo_root/scripts/prepare-release.py" --repo "$repo_root" --version "$version")
if [[ -n "$tap_repo" ]]; then
  cmd+=(--tap-repo "$tap_repo")
fi
"${cmd[@]}"

cat <<EOF

Next steps:
  git -C "$repo_root" add Formula/urlfix.rb dist/ .gitignore README.md scripts tests urlfix
  git -C "$repo_root" commit ...
  git -C "$repo_root" tag $version
  gh release create $version "$repo_root/dist/urlfix-$version.tar.gz" ...
EOF
