class Scala < Formula
  desc "JVM-based programming language"
  homepage "https://www.scala-lang.org/"
  url "https://github.com/scala/scala3/releases/download/3.5.2/scala3-3.5.2.tar.gz"
  sha256 "899de4f9aca56989ce337d8390fbf94967bc70c9e8420e79f375d1c2ad00ff99"
  license "Apache-2.0"

  livecheck do
    url "https://www.scala-lang.org/download/"
    regex(%r{href=.*?download/v?(\d+(?:\.\d+)+)\.html}i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, all: "4fb2e210f8003f7989a7fba07c6f338717bdc5ae5f60e5b22488d0974fca70f1"
  end

  # Switch back to `openjdk` when supported:
  # https://docs.scala-lang.org/overviews/jdk-compatibility/overview.html
  depends_on "openjdk@21"

  conflicts_with "pwntools", because: "both install `common` binaries"

  def install
    rm Dir["bin/*.bat"]
    libexec.install "lib"
    libexec.install "maven2"
    libexec.install "VERSION"
    prefix.install "bin"
    bin.env_script_all_files libexec/"bin", Language::Java.overridable_java_home_env("21")

    # Set up an IntelliJ compatible symlink farm in 'idea'
    idea = prefix/"idea"
    idea.install_symlink libexec/"lib"
  end

  def caveats
    <<~EOS
      To use with IntelliJ, set the Scala home to:
        #{opt_prefix}/idea
    EOS
  end

  test do
    file = testpath/"Test.scala"
    file.write <<~EOS
      object Test {
        def main(args: Array[String]): Unit = {
          println(s"${2 + 2}")
        }
      }
    EOS

    out = shell_output("#{bin}/scala #{file}").strip

    assert_equal "4", out
  end
end
