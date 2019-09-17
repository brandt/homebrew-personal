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
      :tag      => "v0.1.2",
      :revision => "9da56167568138c56da9c87ad95f716c7f15ace0"
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

  # While this could run at startup, at the moment it seems preferable to run
  # it as the regular, unprivileged user when they login.
  plist_options :startup => false, :manual => "awsresolver run"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>KeepAlive</key>
        <true/>
        <key>RunAtLoad</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/awsresolver</string>
          <string>run</string>
        </array>
        <key>StandardErrorPath</key>
        <string>#{var}/log/awsresolver.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/awsresolver.log</string>
      </dict>
    </plist>
  EOS
  end

  test do
    system bin/"awsresolver", "version"
  end
end
