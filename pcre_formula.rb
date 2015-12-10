class PcreFormula < Formula
  homepage "http://www.pcre.org/"
  url      "http://downloads.sourceforge.net/project/pcre/pcre/8.37/pcre-8.37.tar.bz2"
  sha256   "51679ea8006ce31379fb0860e46dd86665d864b5020fc9cd19e71260eef4789d"

  def install
    system "./configure",
      "--disable-dependency-tracking",
      "--prefix=#{prefix}",
      "--enable-utf8",
      "--enable-unicode-properties",
      "--enable-pcregrep-libz"
    system "make test"
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
