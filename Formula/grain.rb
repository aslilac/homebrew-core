class Grain < Formula
  desc "Compiler toolchain and CLI for the Grain programming language. 🌾"
  homepage "https://grain-lang.org/"
  url "https://github.com/grain-lang/grain/archive/refs/tags/grain-v0.4.7.tar.gz"
  sha256 "849ec27beb0dc963284e10800fb7bb3bd87d4c83322effb8dd8df9bfe619edb9"
  license "LGPL-3.0-only"

  depends_on "node@14" => :build
  depends_on "yarn" => :build

  def install
    system "yarn"
    system "yarn", "compiler", "build"
    system "yarn", "compiler", "build:js"
    system "yarn", "cli", "build-pkg"

    cp "./pkg/grain", bin/"grain"
    chmod 755, bin/"grain"
  end

  test do
    (testpath/"test.gr").write <<~EOS
      print("Hello!")
    EOS
    
    assert_match "Hello!\n", shell_output("#{bin}/grain #{testpath}/test.gr")
  end
end
