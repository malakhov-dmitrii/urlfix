class Urlfix < Formula
  desc "Strip whitespace from wrapped URLs and copy the result back to the clipboard"
  homepage "https://github.com/malakhov-dmitrii/urlfix"
  url "https://github.com/malakhov-dmitrii/urlfix/releases/download/v0.1.1/urlfix-v0.1.1.tar.gz"
  sha256 "bb5e3d79347a08b239e8f1f46b60220e0220ab4cc8a9aba02c1351de2a37a879"
  license "MIT"

  def install
    bin.install "urlfix"
  end

  test do
    assert_match "clipboard", shell_output("#{bin}/urlfix --help")
  end
end
