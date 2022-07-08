class Bun < Formula
  desc "Incredibly fast JavaScript runtime, bundler, transpiler and package manager - all in one."
  homepage "https://bun.sh"
  # url "https://github.com/Jarred-Sumner/bun/archive/refs/tags/bun-v0.1.1.tar.gz"
  # Use git for submodules
  url "https://github.com/Jarred-Sumner/bun.git",
      tag:      "bun-v0.1.2",
      revision: "1ee94d5bd261b4cfad7798f0e119499f351b93f3"
  license "MIT" => { with: "LGPL-2.0-linking-exception" }
  head "https://github.com/Jarred-Sumner/bun.git", branch: "main"

  depends_on "automake" => :build
  depends_on "cmake" => :build
  depends_on "coreutils" => :build
  depends_on "esbuild" => :build
  depends_on "gnu-sed" => :build
  depends_on "go" => :build
  depends_on "libiconv" => :build
  depends_on "libtool" => :build
  depends_on "llvm@13" => :build
  depends_on "ninja" => :build
  depends_on "node" => :build
  depends_on "openssl@1.1" => :build
  depends_on "pkg-config" => :build

  # Depends on a custom version of Zig
  resource "zig" do
    url "https://github.com/Jarred-Sumner/zig.git"
  end

  def install
    resource("zig").stage do
      system "cmake", ".", *std_cmake_args(install_prefix: libexec), "-DZIG_STATIC_LLVM=ON"
      system "make", "install"
    end
    
    ENV.deparallelize
    ENV.append_path "PATH", Formula["node"].libexec/"bin"
    ENV["LLVM_PREFIX"] = Formula["llvm@13"].prefix
    ENV["ZIG"] = libexec/"bin/zig"
    
    if OS.mac?
      ENV["MIN_MACOS_VERSION"] = OS::Mac.version

      # Remove when LINK is included in a new release
      # inreplace "Makefile" do |s|
      #   s.gsub!(/^(\s*)MIN_MACOS_VERSION = .+$/, '\1MIN_MACOS_VERSION ?= #{OS::Mac.version}')
      #   s.sub!("LLVM_PREFIX = $(shell brew --prefix llvm)", "LLVM_PREFIX ?= $(shell brew --prefix llvm)")
      # end
    end

    system "make", "vendor"
    system "make", "jsc"
    system "make", "identifier-cache"

    system "false"
    # TODO: What does `make dev` do, and is it what we should be doing?
    # TODO: Probably need to do `zig build --release` or something

    system libexec/"bin/zig", "build"
    bin.install "zig-out/bin/bun"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test bun`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
