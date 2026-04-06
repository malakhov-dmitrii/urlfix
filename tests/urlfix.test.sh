#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

cat > "$tmp_dir/pbcopy" <<'MOCK'
#!/usr/bin/env bash
cat > "$URLFIX_TEST_CLIPBOARD"
MOCK
chmod +x "$tmp_dir/pbcopy"

cat > "$tmp_dir/pbpaste" <<'MOCK'
#!/usr/bin/env bash
cat "$URLFIX_TEST_CLIPBOARD"
MOCK
chmod +x "$tmp_dir/pbpaste"

clipboard_file="$tmp_dir/clipboard.txt"
export URLFIX_TEST_CLIPBOARD="$clipboard_file"
export PATH="$tmp_dir:$PATH"

printf '%s' 'https://example.com/hello wo rld?x=1' > "$clipboard_file"
actual_default="$($repo_root/urlfix)"
expected_default='https://example.com/helloworld?x=1'
[[ "$actual_default" == "$expected_default" ]]
[[ "$(cat "$clipboard_file")" == "$expected_default" ]]

actual_args="$($repo_root/urlfix 'https://example.com/a b' 'c d')"
expected_args='https://example.com/abcd'
[[ "$actual_args" == "$expected_args" ]]
[[ "$(cat "$clipboard_file")" == "$expected_args" ]]

actual_stdin="$(printf 'https://example.com/one\n two\tthree' | $repo_root/urlfix)"
expected_stdin='https://example.com/onetwothree'
[[ "$actual_stdin" == "$expected_stdin" ]]
[[ "$(cat "$clipboard_file")" == "$expected_stdin" ]]

actual_clipboard_flag="$($repo_root/urlfix --clipboard)"
[[ "$actual_clipboard_flag" == "$expected_stdin" ]]

printf 'urlfix tests passed\n'
