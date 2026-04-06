# urlfix

Tiny CLI for fixing wrapped URLs.

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

### Standalone

```bash
git clone https://github.com/malakhov-dmitrii/urlfix.git
cd urlfix
./install.sh
```

### Homebrew

```bash
brew tap malakhov-dmitrii/urlfix
brew install urlfix
```

Or in one line:

```bash
brew install malakhov-dmitrii/urlfix/urlfix
```

## Usage

```bash
urlfix                    # default: clean current clipboard contents
urlfix -o                 # clean clipboard and open the result
urlfix --clipboard        # explicit clipboard mode
urlfix 'https://exa mple.com/a b'
printf 'https://exa\nmple.com/a b' | urlfix
```

## Behavior

- Removes all whitespace characters: spaces, tabs, and newlines.
- Copies the cleaned URL back to your system clipboard.
- Prints the cleaned URL to stdout so you can see what happened.
- `-o` / `--open` opens the cleaned URL after copying it.

## Platform support

- macOS: uses `pbcopy`, `pbpaste`, and `open`
- Linux Wayland: uses `wl-copy`, `wl-paste`, and `xdg-open`
- Linux X11: uses `xclip` or `xsel`, plus `xdg-open`

## Release workflow

```bash
./scripts/release.sh v0.1.2 /Users/malakhov/code/homebrew-urlfix
```

This will run tests, rebuild the release tarball, and update the Homebrew formulas in both repos so you only have to commit, tag, and publish.

## Test

```bash
./tests/urlfix.test.sh
```

## License

MIT
