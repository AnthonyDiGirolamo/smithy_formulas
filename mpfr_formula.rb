class MpfrFormula < Formula
  homepage "http://www.mpfr.org/"
  url "http://www.mpfr.org/mpfr-current/mpfr-3.1.3.tar.bz2"
  sha1 "3e46c5ce43701f2f36f9d01f407efe081700da80"

  depends_on "gmp"
  def install
    module_list
    system "./configure --prefix=#{prefix} --with-gmp=#{gmp.prefix}"
    system "make"
    system "make install"
  end
  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path MANPATH         $PREFIX/share/man
  MODULEFILE
end
