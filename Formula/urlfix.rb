class Urlfix < Formula
  desc "Fix wrapped URLs by stripping whitespace and copying the result back to the clipboard"
  homepage "https://github.com/malakhov-dmitrii/urlfix"
  url "https://github.com/malakhov-dmitrii/urlfix/releases/download/v0.1.0/urlfix-v0.1.0.tar.gz"
  sha256 "d085714a1ae83426c8da23d6b0fd7037318938d1abda8bf10e39a8ce97c2b848"
  license "MIT"

  def install
    bin.install "urlfix"
  end

  test do
    assert_match "clipboard", shell_output("#{bin}/urlfix --help")
  end
end
