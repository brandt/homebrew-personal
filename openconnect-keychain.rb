# openconnect-keychain Formula
#
# Install with:
#
#   brew install brandt/personal/openconnect-keychain
#

class OpenconnectKeychain < Formula
  desc "Openconnect client with Mac OS X Keychain support"
  homepage "https://github.com/brandt/openconnect"
  url "https://github.com/brandt/openconnect/archive/v7.08-2.keychain.tar.gz"
  version "7.08-2"
  sha256 "3a0bfd796e33ba0045d698b7d6902fa3acd0c16df1da4238b1888ab68a8f2a2c"

  head do
    url "https://github.com/brandt/openconnect.git", :branch => "devel"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build

  depends_on "gettext"
  depends_on "gnutls"
  depends_on "oath-toolkit" => :optional
  depends_on "stoken" => :optional

  resource "vpnc-script" do
    url "http://git.infradead.org/users/dwmw2/vpnc-scripts.git/blob_plain/6e04e0bbb66c0bf0ae055c0f4e58bea81dbb5c3c:/vpnc-script"
    sha256 "48b1673e1bfaacbfa4e766c41e15dd8458726cca8f3e07991d078d0d5b7c55e9"
  end

  def install
    etc.install resource("vpnc-script")
    chmod 0755, "#{etc}/vpnc-script"

    ENV["LIBTOOLIZE"] = "glibtoolize"
    system "./autogen.sh"

    args = %W[
      --prefix=#{prefix}
      --sbindir=#{bin}
      --localstatedir=#{var}
      --with-vpnc-script=#{etc}/vpnc-script
      --program-suffix=-keychain
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match /AnyConnect VPN/, pipe_output("#{bin}/openconnect-keychain 2>&1")
  end
end
