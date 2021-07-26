class MacFuseRequirement < Requirement
  fatal true

  satisfy(build_env: false) { self.class.binary_mac_fuse_installed? }

  def self.binary_mac_fuse_installed?
    File.exist?("/usr/local/include/fuse.h") &&
      !File.symlink?("/usr/local/include")
  end

  env do
    ENV.append_path "PKG_CONFIG_PATH", HOMEBREW_LIBRARY/"Homebrew/os/mac/pkgconfig/fuse"

    unless HOMEBREW_PREFIX.to_s == "/usr/local"
      ENV.append_path "HOMEBREW_LIBRARY_PATHS", "/usr/local/lib"
      ENV.append_path "HOMEBREW_INCLUDE_PATHS", "/usr/local/include/fuse"
    end
  end

  def message
    "macFUSE is required. Please run `brew install --cask macfuse` first."
  end
end

class FuseXfs < Formula
  desc "Read-only XFS driver for macFUSE"
  homepage "https://fusexfs.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/fusexfs/releases/fuse-xfs-0.2.1.tar.gz"
  sha256 "4c16e3efbb8adbe47c9ee5fc20781bd5f19c33638b78140fdc5d643b6bf6c140"
  head "http://hg.code.sf.net/p/fusexfs/trunk", :using => :hg

  depends_on MacFuseRequirement => :build
  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    ENV.deparallelize

    # Building the DMG requires root, so we don't build it
    inreplace "src/Makefile", "all: $(PROGRAMS) $(DMG)", "all: $(PROGRAMS)"

    # TODO: It would be better to do this as a patch.
    inreplace "src/Make.inc", "osxfuse", "fuse"

    cd "src" do
      system "make"
    end

    cd "build/bin" do
      bin.install "fuse-xfs"
      bin.install "mkfs.xfs"
      bin.install "xfs-cli"
      bin.install "xfs-rcopy"
    end

    man1.install "man/fuse-xfs.1"
    man8.install "man/mkfs.xfs.8"
  end

  def caveats; <<~EOS
    To use:

        1. If mounting a raw disk image, attach it:

            hdiutil attach -imagekey diskimage-class=CRawDiskImage -nomount <ImgPath>

        2. Determine its disk device name (example: 'disk4s1'):

            diskutil list

        3. Create a mount directory:

            sudo mkdir /Volumes/<AnyName>

        4. Mount the volume:

            sudo fuse-xfs /dev/r<DeviceName> -- /Volumes/<VolumeName>
    EOS
  end

  test do
    system "#{bin}/mkfs.xfs", "-V"
  end
end
