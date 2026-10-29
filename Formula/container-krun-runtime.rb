# Rendered by scripts/publish-homebrew.sh on each release and pushed to the
# RobertDeRose/homebrew-tap repository. 0.9.1 and 2defb070fbc9e2ce989ae9fb5a4cf128f882539a4c85d14fb301fe628f200cbb are filled in.
class ContainerKrunRuntime < Formula
  desc "Apple Container runtime that returns freed guest memory to macOS"
  homepage "https://robertderose.github.io/container-krun-runtime/"
  url "https://github.com/RobertDeRose/container-krun-runtime/releases/download/v0.9.1/container-krun-runtime-0.9.1-darwin-aarch64.tar.gz"
  sha256 "2defb070fbc9e2ce989ae9fb5a4cf128f882539a4c85d14fb301fe628f200cbb"
  version "0.9.1"
  license "Apache-2.0"

  depends_on "container"
  depends_on arch: :arm64
  depends_on macos: :tahoe

  # Install the signed binaries byte for byte. libkrun's @rpath install name
  # is unused (the helper dlopens it by path); this stops Homebrew from
  # rewriting it, which would alter code that setup installs as root.
  preserve_rpath

  def install
    # The archive is the package setup installs; keep it whole under libexec.
    libexec.install Dir["*"], ".container-krun-runtime"
    bin.install_symlink libexec/"cli/container-krun-runtime-setup"
  end

  def caveats
    <<~EOS
      Register the runtime with container. It asks for sudo once to install
      the root-owned network helper; pass --no-network to skip that:
        container-krun-runtime-setup
        container system stop && container system start
      Run it again after upgrading container-krun-runtime or container.
      Then run containers with:
        container run --runtime container-krun-runtime alpine echo hello
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{libexec}/bin/container-krun-runtime --version")
  end
end
