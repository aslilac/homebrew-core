require "language/node"

class AngularCli < Formula
  desc "CLI tool for Angular"
  homepage "https://cli.angular.io/"
  url "https://registry.npmjs.org/@angular/cli/-/cli-17.0.5.tgz"
  sha256 "f13d0d1e66553e71599be18d17e8056cbb5e83114828f6482f6f281bfd636382"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "dc23b7b49c605ec2596932967271125b354d457075bbf2c36e12008867690419"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "dc23b7b49c605ec2596932967271125b354d457075bbf2c36e12008867690419"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "dc23b7b49c605ec2596932967271125b354d457075bbf2c36e12008867690419"
    sha256 cellar: :any_skip_relocation, sonoma:         "edc68e8aba28d7423ab6a667071ad63bd174ef9f1ace3557150e8a3a4573c0f9"
    sha256 cellar: :any_skip_relocation, ventura:        "edc68e8aba28d7423ab6a667071ad63bd174ef9f1ace3557150e8a3a4573c0f9"
    sha256 cellar: :any_skip_relocation, monterey:       "edc68e8aba28d7423ab6a667071ad63bd174ef9f1ace3557150e8a3a4573c0f9"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "dc23b7b49c605ec2596932967271125b354d457075bbf2c36e12008867690419"
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"ng", "new", "angular-homebrew-test", "--skip-install"
    assert_predicate testpath/"angular-homebrew-test/package.json", :exist?, "Project was not created"
  end
end
