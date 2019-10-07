class MacosPasteboard < Formula
  desc "Like macOS's built-in pbpaste but more flexible and raw"
  homepage "https://github.com/chbrown/macos-pasteboard"
  version "0.0.1"
  url "https://github.com/chbrown/macos-pasteboard.git",
      :revision => "22653fc5edfbfd420b8d8425b41bdf3d048f8092"

  def install
    system "make", "pbv"
    bin.install "pbv"
  end

  test do
    system bin/"pbv", "-h"
  end
end
