class LibgdFormula < Formula
  homepage "http://libgd.bitbucket.org/"
  url "https://bitbucket.org/libgd/gd-libgd/downloads/libgd-2.1.0.tar.bz2"

  module_commands ["purge"]

  def install
    module_list
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
