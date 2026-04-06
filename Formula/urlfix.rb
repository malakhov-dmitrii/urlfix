class Urlfix < Formula
  desc "Strip whitespace from wrapped URLs and copy the result back to the clipboard"
  homepage "https://github.com/malakhov-dmitrii/urlfix"
  url "https://github.com/malakhov-dmitrii/urlfix/releases/download/v0.1.2/urlfix-v0.1.2.tar.gz"
  sha256 "bfd59f2c561c181e047a9d9ba3130b0012e90f7cb69a9eb9a235a9cda66c00c0"
  license "MIT"

  def install
    bin.install "urlfix"
  end

  test do
    assert_match "clipboard", shell_output("#{bin}/urlfix --help")
  end
end
