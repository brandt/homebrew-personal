# openconnect-keychain Formula
#
# Install with:
#
#   brew install brandt/personal/openconnect-keychain
#
# If for some reason you need to go back to the old version of openconnect-keychain, you can reinstall the v7.08-2 release by running:
#
#     brew uninstall openconnect-keychain
#     brew install https://raw.githubusercontent.com/brandt/homebrew-personal/5dfb11b/openconnect-keychain.rb
#

class OpenconnectKeychain < Formula
  desc "Openconnect client with Mac OS X Keychain support"
  homepage "https://github.com/brandt/openconnect"
  url "https://github.com/brandt/openconnect/archive/v8.05-1.keychain.tar.gz"
  version "8.05-1"
  revision 2
  sha256 "a910573d1193e39e59f2963d8a090729d95dcbc1c9b3734548f5d686db6edcfe"

  head do
    # url "#{ENV['HOME']}/src/openconnect-keychain/.git/", branch: "v8_05-devel", using: :git
    url "https://github.com/brandt/openconnect.git", branch: "devel"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build

  depends_on "gettext"
  depends_on "gnutls"
  depends_on "stoken"
  depends_on "oath-toolkit" => :optional

  option "with-generic-script", "use the upstream generic vpnc-script by default"

  # https://github.com/brandt/vpnc-scripts
  resource "vpnc-script-mac" do
    url "https://raw.githubusercontent.com/brandt/vpnc-scripts/d86d822e1208d899ebf76f48730c1fb6f6c84785/vpnc-script"
    sha256 "1e93713056d77d368bffbbe73930a802b03c15f6e195dffbcea5ab4b42f8c762"
  end

  # http://git.infradead.org/users/dwmw2/vpnc-scripts.git
  resource "vpnc-script-generic" do
    url "http://git.infradead.org/users/dwmw2/vpnc-scripts.git/blob_plain/c84fb8e5a523a647a01a1229a9104db934e19f00:/vpnc-script"
    sha256 "20f05baf2857cb48073aca8b90d84ddc523f09b9700a5986a2f7e60e76917385"
  end

  def install
    # Install both so the user still has the option to use the non-default
    # script by providing the '--script=PATH' flag.
    resource("vpnc-script-generic").stage do
      chmod 0755, "vpnc-script"
      mv "vpnc-script", "vpnc-script-generic"
      etc.install "vpnc-script-generic"
    end

    resource("vpnc-script-mac").stage do
      chmod 0755, "vpnc-script"
      mv "vpnc-script", "vpnc-script-mac"
      etc.install "vpnc-script-mac"
    end

    default_script = build.with?("generic-script") ? "vpnc-script-generic" : "vpnc-script-mac"

    ENV["LIBTOOLIZE"] = "glibtoolize"
    system "./autogen.sh"

    args = %W[
      --prefix=#{prefix}
      --sbindir=#{bin}
      --localstatedir=#{var}
      --with-vpnc-script=#{etc}/#{default_script}
      --program-suffix=-keychain
    ]

    system "./configure", *args
    system "make", "install"
  end

  def caveats; <<~EOS
      Pulse Secure users with push-based 2FA:

      You can automatically send "push" at the "password#2" prompt with this flag:

          --form-entry="frmLogin:password#2=push"
    EOS
  end

  test do
    assert_match "Open client for multiple VPN protocols", pipe_output("#{bin}/openconnect-keychain 2>&1")
  end
end
