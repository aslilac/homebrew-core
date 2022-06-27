require "language/node"

class Grain < Formula
  desc "Compiler toolchain and CLI for the Grain programming language. 🌾"
  homepage "https://grain-lang.org/"
  url "https://github.com/grain-lang/grain/archive/refs/tags/grain-v0.5.1.tar.gz"
  sha256 "25fc6107aef537c4cdc9889e29f5b019f44509a19035dd38419ee078cc335014"
  license "LGPL-3.0-only"

  depends_on "node@16" => :build

  def install
    system "npm", "install", "--ignore-scripts", *Language::Node.local_npm_install_args
    system "npm", "run", "compiler", "build"

    cp "./pkg/grain", bin/"grain"
    chmod 755, bin/"grain"
  end

  test do
    (testpath/"test.gr").write <<~EOS
      print("Hello Homebrew!")
    EOS
    
    assert_match "Hello Homebrew!\n", shell_output("#{bin}/grain #{testpath}/test.gr")
  end
end
