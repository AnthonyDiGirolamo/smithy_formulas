class GluFormula < Formula
  homepage "http://osmesa.org"
  url      "ftp://ftp.freedesktop.org/pub/mesa/glu/glu-9.0.0.tar.gz"

  def install
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
  #%Module

  set PREFIX <%= @package.prefix %>

  setenv GLU_ROOT $PREFIX
  prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
  prepend LD_LIBRARY_PATH $PREFIX/lib
  MODULEFILE
end
