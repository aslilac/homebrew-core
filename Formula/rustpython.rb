class Rustpython < Formula
  desc "Python interpreter written in Rust"
  homepage "https://rustpython.github.io"
  url "https://github.com/RustPython/RustPython/archive/174c0267276f3ba617cebc7cba3c79a607474615.tar.gz"
  sha256 "3aa331e64d52e835df70b47b9ab54af660923afd219c176225efc1a14d520a37"
  license "MIT"
  head "https://github.com/RustPython/RustPython.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "-vv", *std_cargo_args
  end

  test do
    (testpath/"hello.py").write <<~EOS
      if __name__ == "__main__":
        name = "python"
        print(f"hello from {name}")
    EOS
    assert_match "hello from python", shell_output("#{bin}/rustpython ./hello.py")
  end
end
