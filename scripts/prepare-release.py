#!/usr/bin/env python3
from __future__ import annotations

import argparse
import gzip
import hashlib
import io
import tarfile
from pathlib import Path


def formula_text(version: str, sha256: str) -> str:
    return f'''class Urlfix < Formula
  desc "Strip whitespace from wrapped URLs and copy the result back to the clipboard"
  homepage "https://github.com/malakhov-dmitrii/urlfix"
  url "https://github.com/malakhov-dmitrii/urlfix/releases/download/{version}/urlfix-{version}.tar.gz"
  sha256 "{sha256}"
  license "MIT"

  def install
    bin.install "urlfix"
  end

  test do
    assert_match "clipboard", shell_output("#{{bin}}/urlfix --help")
  end
end
'''


def add_file_to_tar(tar: tarfile.TarFile, src: Path, arcname: str) -> None:
    data = src.read_bytes()
    info = tarfile.TarInfo(name=arcname)
    info.size = len(data)
    info.mtime = 0
    info.uid = 0
    info.gid = 0
    info.uname = "root"
    info.gname = "wheel"
    info.mode = 0o755 if src.stat().st_mode & 0o111 else 0o644
    tar.addfile(info, io.BytesIO(data))


def build_tarball(repo: Path, version: str) -> tuple[Path, str]:
    dist = repo / "dist"
    dist.mkdir(exist_ok=True)
    tarball = dist / f"urlfix-{version}.tar.gz"

    with tarball.open("wb") as raw:
        with gzip.GzipFile(filename="", mode="wb", fileobj=raw, mtime=0) as gz:
            with tarfile.open(fileobj=gz, mode="w") as tar:
                for name in ["urlfix", "README.md", "LICENSE"]:
                    add_file_to_tar(tar, repo / name, name)

    sha256 = hashlib.sha256(tarball.read_bytes()).hexdigest()
    return tarball, sha256


def write_formula(repo: Path, version: str, sha256: str) -> Path:
    formula_dir = repo / "Formula"
    formula_dir.mkdir(exist_ok=True)
    formula_path = formula_dir / "urlfix.rb"
    formula_path.write_text(formula_text(version, sha256))
    return formula_path


def main() -> None:
    parser = argparse.ArgumentParser(description="Build a deterministic urlfix release asset and update Homebrew formulas.")
    parser.add_argument("--version", required=True, help="Release tag, e.g. v0.1.2")
    parser.add_argument("--repo", default=".", help="Path to the urlfix source repo")
    parser.add_argument("--tap-repo", help="Optional path to the homebrew-urlfix tap repo")
    args = parser.parse_args()

    repo = Path(args.repo).resolve()
    tarball, sha256 = build_tarball(repo, args.version)
    source_formula = write_formula(repo, args.version, sha256)

    if args.tap_repo:
        tap_formula = write_formula(Path(args.tap_repo).resolve(), args.version, sha256)
        print(f"updated_tap_formula={tap_formula}")

    print(f"tarball={tarball}")
    print(f"sha256={sha256}")
    print(f"source_formula={source_formula}")


if __name__ == "__main__":
    main()
