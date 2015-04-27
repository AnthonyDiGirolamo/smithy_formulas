class Libxml2Formula < Formula
  homepage "http://www.linuxfromscratch.org/blfs/view/svn/general/libxml2.html"
  url      "http://xmlsoft.org/sources/libxml2-2.9.2.tar.gz"

  def install
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
  #%Module
  prepend-path PKG_CONFIG_PATH
  MODULEFILE
end
