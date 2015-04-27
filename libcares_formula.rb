class LibcaresFormula < Formula
  homepage "http://c-ares.haxx.se/"
  url      "http://c-ares.haxx.se/download/c-ares-1.10.0.tar.gz"

  def install
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
