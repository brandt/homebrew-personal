# awsresolver
#
# Install from HEAD with:
#
#   brew install --HEAD brandt/personal/awsresolver
#
# Upgrade from HEAD with:
#
#   brew reinstall --HEAD brandt/personal/awsresolver
#

require "language/go"

class Awsresolver < Formula
  desc "DNS resolver that decodes AWS EC2 internal hostnames"
  homepage "https://github.com/brandt/awsresolver"
  head "https://github.com/brandt/awsresolver.git"
  url "https://github.com/brandt/awsresolver.git",
      :tag      => "v0.1.0",
      :revision => "af5e58f9bb364b6be3d426b007e783e66909e6fd"

  depends_on "go" => :build

  def install
    # ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "on"

    mkdir_p buildpath
    ln_sf buildpath, buildpath/"awsresolver"

    cd "awsresolver" do
      system "go", "mod", "vendor"
      system "make", "bin"
      bin.install buildpath/"bin/awsresolver"
      prefix.install_metafiles
    end
  end

  test do
    system bin/"awsresolver", "version"
  end
end
