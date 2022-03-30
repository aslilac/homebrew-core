class Rustpython < Formula
  desc "Python interpreter written in Rust"
  homepage "https://rustpython.github.io"
  url "https://github.com/RustPython/RustPython/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "14c2786b28072006de1f9035487b0f65a9d1972d7e1f3fe4a2f9a39645290da8"
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
