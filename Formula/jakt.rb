class Jakt < Formula
  desc "Jakt programming language"
  homepage "https://github.com/SerenityOS/jakt"
  url "https://github.com/SerenityOS/jakt/archive/f329e095c18c599597801328490ff3f444194303.tar.gz"
  version "1.0.0"
  sha256 "1a5b3ff0744e9af09cefe12d213ff6df2993b67bd4be0ed4b9ad64525aeeeeb3"
  license "BSD-2-Clause"

  depends_on "rust" => :build

  uses_from_macos "llvm"

  def install
    system "cargo", "install", *std_cargo_args
    lib.install "runtime"
  end

  test do
    (testpath/"test.jakt").write <<~EOS
      class Friend {
        name: String
      
        public function say_hi(this) {
          println("Hello {}!", .name);
        }
      }

      function main() {
        let names = ["Homebrew"]

        for name in names.iterator() {
          let fren = Friend(name)
          fren.say_hi();
        }
      }
    EOS

    system bin/"jakt", "-R", lib/"runtime", "./test.jakt"
    assert_match "Hello Homebrew!", shell_output("./build/test")
  end
end
