# urlfix

Tiny macOS CLI for fixing wrapped URLs.

Copy a broken URL, run `urlfix`, and the tool removes every whitespace character, prints the cleaned URL, and writes the cleaned value back to your clipboard.

## Why

Some apps copy long OAuth links or magic links with line wraps in the middle. `urlfix` turns this:

```text
https://example.com/ab
cd?x=1 2
```

into this:

```text
https://example.com/abcd?x=12
```

## Install

```bash
git clone https://github.com/malakhov-dmitrii/urlfix.git
cd urlfix
./install.sh
```

The installer copies the script to `~/.local/bin/urlfix`.

## Usage

```bash
urlfix                 # default: clean current clipboard contents
urlfix --clipboard     # explicit clipboard mode
urlfix 'https://exa mple.com/a b'
printf 'https://exa\nmple.com/a b' | urlfix
```

## Behavior

- Removes all whitespace characters: spaces, tabs, and newlines.
- Copies the cleaned URL to the macOS clipboard with `pbcopy`.
- Prints the cleaned URL to stdout so you can see what happened.

## Test

```bash
./tests/urlfix.test.sh
```

## License

MIT
