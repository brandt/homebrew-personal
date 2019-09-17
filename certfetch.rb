# certfetch HEAD-only Formula
#
# Install with:
#
#   brew tap brew tap brandt/personal
#   brew install --HEAD certfetch
#
# Upgrade with:
#
#   brew update
#   brew reinstall --HEAD certfetch

class Certfetch < Formula
  desc "Command-line tool for fetching certificates"
  homepage "https://github.com/brandt/certfetch"
  head "https://github.com/brandt/certfetch.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath/"src/github.com/brandt/certfetch"
    mkdir_p buildpath/"src/github.com/brandt/"
    ln_sf buildpath, buildpath/"src/github.com/brandt/certfetch"

    system "go", "build", "-o", "certfetch", "."
    bin.install "certfetch"
  end

  test do
    system bin/"certfetch", "github.com"
  end
end
