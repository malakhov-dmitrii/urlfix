#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install_dir="${HOME}/.local/bin"
mkdir -p "$install_dir"
install -m 0755 "$repo_root/urlfix" "$install_dir/urlfix"
printf 'Installed urlfix to %s\n' "$install_dir/urlfix"
