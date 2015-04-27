class BisonFormula < Formula
  homepage "http://ftp.gnu.org/gnu/bison/"
  url      "http://ftp.gnu.org/gnu/bison/bison-1.25.tar.gz"

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
