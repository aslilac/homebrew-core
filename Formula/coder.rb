# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Coder < Formula
  desc "A tool for provisioning self-hosted development environments with Terraform."
  homepage "https://coder.com"
  url "https://github.com/coder/coder/archive/refs/tags/v2.0.2.tar.gz"
  sha256 "a9c2a996cb916ef0d74c1cdd2ccf30f95b9953618ce2d504a7477eb2b8b655c2"
  license "AGPL-3.0-only"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/coder"
  end

  test do
    assert_match "Coder", shell_output("#{bin}/coder version")
    assert_match "You are not logged in", shell_output("#{bin}/coder netcheck 2>&1", 1)
    assert_match "postgres://", shell_output("#{bin}/coder server postgres-builtin-url")
  end
end
