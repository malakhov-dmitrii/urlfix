#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

make_mock_command() {
  local dir="$1"
  local name="$2"
  shift 2
  cat > "$dir/$name" <<EOF_CMD
#!/usr/bin/env bash
set -euo pipefail
$*
EOF_CMD
  chmod +x "$dir/$name"
}

run_with_mocks() {
  local os_name="$1"
  local body="$2"
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' RETURN

  export URLFIX_TEST_CLIPBOARD="$tmp_dir/clipboard.txt"
  export URLFIX_TEST_OPENED_URL="$tmp_dir/opened-url.txt"
  export URLFIX_OS_OVERRIDE="$os_name"
  export PATH="$tmp_dir:$PATH"

  eval "$body"
}

run_with_mocks Darwin '
  make_mock_command "$tmp_dir" pbcopy "cat > \"\$URLFIX_TEST_CLIPBOARD\""
  make_mock_command "$tmp_dir" pbpaste "cat \"\$URLFIX_TEST_CLIPBOARD\""
  make_mock_command "$tmp_dir" open "printf \"%s\" \"\${1:-}\" > \"\$URLFIX_TEST_OPENED_URL\""

  printf "%s" "https://example.com/hello wo rld?x=1" > "$URLFIX_TEST_CLIPBOARD"
  actual_default="$($repo_root/urlfix)"
  expected_default="https://example.com/helloworld?x=1"
  [[ "$actual_default" == "$expected_default" ]]
  [[ "$(cat "$URLFIX_TEST_CLIPBOARD")" == "$expected_default" ]]

  actual_args="$($repo_root/urlfix "https://example.com/a b" "c d")"
  expected_args="https://example.com/abcd"
  [[ "$actual_args" == "$expected_args" ]]
  [[ "$(cat "$URLFIX_TEST_CLIPBOARD")" == "$expected_args" ]]

  actual_stdin="$(printf "https://example.com/one\n two\tthree" | $repo_root/urlfix)"
  expected_stdin="https://example.com/onetwothree"
  [[ "$actual_stdin" == "$expected_stdin" ]]
  [[ "$(cat "$URLFIX_TEST_CLIPBOARD")" == "$expected_stdin" ]]

  actual_clipboard_flag="$($repo_root/urlfix --clipboard)"
  [[ "$actual_clipboard_flag" == "$expected_stdin" ]]

  actual_open="$($repo_root/urlfix -o "https://example.com/a b")"
  expected_open="https://example.com/ab"
  [[ "$actual_open" == "$expected_open" ]]
  [[ "$(cat "$URLFIX_TEST_OPENED_URL")" == "$expected_open" ]]
'

run_with_mocks Linux '
  make_mock_command "$tmp_dir" wl-copy "cat > \"\$URLFIX_TEST_CLIPBOARD\""
  make_mock_command "$tmp_dir" wl-paste "cat \"\$URLFIX_TEST_CLIPBOARD\""
  make_mock_command "$tmp_dir" xdg-open "printf \"%s\" \"\${1:-}\" > \"\$URLFIX_TEST_OPENED_URL\""

  printf "%s" "https://example.com/way land" > "$URLFIX_TEST_CLIPBOARD"
  actual_linux_default="$($repo_root/urlfix)"
  expected_linux_default="https://example.com/wayland"
  [[ "$actual_linux_default" == "$expected_linux_default" ]]
  [[ "$(cat "$URLFIX_TEST_CLIPBOARD")" == "$expected_linux_default" ]]

  actual_linux_open="$($repo_root/urlfix -o)"
  [[ "$actual_linux_open" == "$expected_linux_default" ]]
  [[ "$(cat "$URLFIX_TEST_OPENED_URL")" == "$expected_linux_default" ]]
'

run_with_mocks Linux '
  make_mock_command "$tmp_dir" xclip "if [[ \"\${1:-}\" == \"-selection\" && \"\${2:-}\" == \"clipboard\" && \"\${3:-}\" == \"-o\" ]]; then cat \"\$URLFIX_TEST_CLIPBOARD\"; elif [[ \"\${1:-}\" == \"-selection\" && \"\${2:-}\" == \"clipboard\" ]]; then cat > \"\$URLFIX_TEST_CLIPBOARD\"; else exit 1; fi"

  printf "%s" "https://example.com/x cli p" > "$URLFIX_TEST_CLIPBOARD"
  actual_xclip="$($repo_root/urlfix --clipboard)"
  expected_xclip="https://example.com/xclip"
  [[ "$actual_xclip" == "$expected_xclip" ]]
  [[ "$(cat "$URLFIX_TEST_CLIPBOARD")" == "$expected_xclip" ]]
'

printf 'urlfix tests passed\n'
