class Podman < Formula
  desc "Tool for managing OCI containers and pods"
  homepage "https://podman.io/"
  license "Apache-2.0"

  stable do
    url "https://github.com/containers/podman/archive/v4.1.0.tar.gz"
    sha256 "f814e12a7311d486c1ccdc4eb021bc6dd24499569de7a572e436342876f70e95"
    resource "gvproxy" do
      url "https://github.com/containers/gvisor-tap-vsock/archive/v0.3.0.tar.gz"
      sha256 "6ca454ae73fce3574fa2b615e6c923ee526064d0dc2bcf8dab3cca57e9678035"
    end
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "34b03da74b82f34694d6f464ff77898d1fe707a63ed3349d19c87763793bd272"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "7bc69157851c143df0ba30e985ff0595e5ed4f3d3ce67be896eb43d5aec3fa6d"
    sha256 cellar: :any_skip_relocation, monterey:       "856d167796145995c33442db516e427ec441883ac1378ef48b3d2fd801fedcb8"
    sha256 cellar: :any_skip_relocation, big_sur:        "6a0e56bcc3f326dd293de7b735fed378fcf5a026d2293d18c7a9c9fe874f069b"
    sha256 cellar: :any_skip_relocation, catalina:       "b815a6573cf499978877e5512d3a18586bbf76a603b02cf331b377fd58355344"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "5e744b5d2c8d7e8808d9e1fb42a72ecdd25a42ae7c4c33e89634c8165bcd5413"
  end

  head do
    url "https://github.com/containers/podman.git", branch: "main"

    resource "gvproxy" do
      url "https://github.com/containers/gvisor-tap-vsock.git", branch: "main"
    end
  end

  depends_on "go" => :build
  depends_on "go-md2man" => :build
  depends_on "qemu"
  depends_on "xz"

  uses_from_macos "zlib"

  def install
    ENV["CGO_ENABLED"] = "1"
    os = OS.kernel_name.downcase

    inreplace "vendor/github.com/containers/common/pkg/config/config_#{os}.go",
              "/usr/local/libexec/podman",
              libexec

    system "make", "podman-remote-#{os}"
    if OS.mac?
      bin.install "bin/#{os}/podman" => "podman-remote"
      bin.install_symlink bin/"podman-remote" => "podman"
      bin.install "bin/#{os}/podman-mac-helper" => "podman-mac-helper"
    else
      bin.install "bin/podman-remote"
    end

    resource("gvproxy").stage do
      system "make", "gvproxy"
      libexec.install "bin/gvproxy"
    end

    system "make", "podman-remote-#{os}-docs"
    man1.install Dir["docs/build/remote/#{os}/*.1"]

    bash_completion.install "completions/bash/podman"
    zsh_completion.install "completions/zsh/_podman"
    fish_completion.install "completions/fish/podman.fish"
  end

  test do
    # To update these resources:
    # 1. Go to https://builds.coreos.fedoraproject.org/streams/testing.json
    # 2. Find "architectures"."aarch64"."artifacts"."qemu"."formats"."qcow2.xz"."disk"
    # 3. Use those values to fill the first case
    # 4. Find "architectures"."x86_64"."artifacts"."qemu"."formats"."qcow2.xz"."disk"
    # 5. Use those values to fill the second case
    resource "fcos" do
      if Hardware::CPU.arm?
        url "https://builds.coreos.fedoraproject.org/prod/streams/testing/builds/36.20220605.2.0/aarch64/fedora-coreos-36.20220605.2.0-qemu.aarch64.qcow2.xz"
        sha256 "d6af2fc8e9cb63777bebd3cb4fb9ea8f6576810b65a98ca49252403c7aa5cb73"
      elsif Hardware::CPU.intel?
        url "https://builds.coreos.fedoraproject.org/prod/streams/testing/builds/36.20220605.2.0/x86_64/fedora-coreos-36.20220605.2.0-qemu.x86_64.qcow2.xz"
        sha256 "46291e2b77177e803903f70e0e87c1c0265c8100b450de372538d6ad1df3b981"
      end
    end

    assert_match "podman-remote version #{version}", shell_output("#{bin}/podman-remote -v")
    assert_match(/Cannot connect to Podman/i, shell_output("#{bin}/podman-remote info 2>&1", 125))

    machineinit_output = shell_output("podman-remote machine init --image-path fake-testi123 fake-testvm 2>&1", 125)
    assert_match "Error: open fake-testi123: no such file or directory", machineinit_output

    # `podman machine init` will fail if $HOME/.ssh/ doesn't exist
    mkdir ".ssh"

    image_path = resource("fcos").stage testpath
    system bin/"podman-remote", "machine", "init", "--image-path", image_path[0][0].basename
    system bin/"podman-remote", "machine", "start"
    system bin/"podman-remote", "run", "hello-world"
    system bin/"podman-remote", "machine", "rm", "-f"
  end
end
