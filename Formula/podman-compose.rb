class PodmanCompose < Formula
  include Language::Python::Virtualenv

  desc "Alternative to docker-compose using podman"
  homepage "https://github.com/containers/podman-compose"
  url "https://github.com/containers/podman-compose/archive/refs/tags/v1.0.3.tar.gz"
  sha256 "b28e5792a50feee987e7864e0df1b6e8929c923c010e1f65493fe29b4c2aedcf"
  license "GPL-2.0-only"

  depends_on "podman"
  depends_on "python@3.9"

  resource "python-dotenv" do
    url "https://files.pythonhosted.org/packages/02/ee/43e1c862a3e7259a1f264958eaea144f0a2fac9f175c1659c674c34ea506/python-dotenv-0.20.0.tar.gz"
    sha256 "b7e3b04a59693c42c36f9ab1cc2acc46fa5df8c78e178fc33a8d4cd05c8d498f"
  end

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/36/2b/61d51a2c4f25ef062ae3f74576b01638bebad5e045f747ff12643df63844/PyYAML-6.0.tar.gz"
    sha256 "68fb519c14306fec9720a2a5b45bc9f0c8d1b9c72adf45c37baedfcd949c35a2"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    port = free_port

    (testpath/"docker-compose.yml").write <<~EOS
      version: "3"
      services:
        test:
          image: nginx:1.22
          ports:
            - #{port}:80
          environment:
            - NGINX_PORT=80
    EOS

    # `podman machine init` will fail if $HOME/.ssh/ doesn't exist
    mkdir ".ssh"

    begin
      system "podman-remote", "machine", "init"
      system "podman-remote", "machine", "start"

      begin
        system bin/"podman-compose", "up", "-d"
        output = shell_output("curl -i localhost:#{port}")
        assert_match "HTTP/1.1 200 OK", output
        assert_match "Welcome to nginx!", output
      ensure
        system bin/"podman-compose", "down"
      end
    ensure
      system "podman-remote", "machine", "rm", "-f"
    end
  end
end
