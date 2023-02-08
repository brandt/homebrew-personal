# awsresolver
#
# Install with:
#
#     brew install brandt/personal/awsresolver
#

class Awsresolver < Formula
  desc "DNS resolver that decodes AWS EC2 internal hostnames"
  homepage "https://github.com/brandt/awsresolver"
  url "https://github.com/brandt/awsresolver.git",
      tag:      "v0.1.2",
      revision: "9da56167568138c56da9c87ad95f716c7f15ace0"
  head "https://github.com/brandt/awsresolver.git"

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

  def caveats
    <<~EOS
      If you want DNS queries for "*.internal" to be automatically sent to
      awsresolver, run this command:

          sudo awsresolver setup
    EOS
  end

  service do
    run [opt_bin/"awsresolver", "run"]
    run_type :immediate
    keep_alive true
    log_path var/"log/awsresolver.log"
    error_log_path var/"log/awsresolver.log"
  end

  test do
    system bin/"awsresolver", "version"
  end
end
