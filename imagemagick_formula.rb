class ImagemagickFormula < Formula
  homepage "http://www.imagemagick.org"
  # upstream's stable tarballs tend to disappear, so we provide our own mirror
  # Tarball from: http://www.imagemagick.org/download/ImageMagick.tar.gz
  # SHA-256 from: http://www.imagemagick.org/download/digest.rdf
  url "http://downloads.sf.net/project/machomebrew/mirror/ImageMagick-6.8.6-3.tar.bz2"
  sha256 "63b9ff1dc7cf8e7776e95c8e834c819eff5b09592728b5cdd810539e7c69e0cd"

  module_commands [ "purge" ]

  def install
    module_list
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make check"
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

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
    prepend-path MANPATH         $PREFIX/share/man
    setenv       IMAGEMAGICDIR   $PREFIX
  MODULEFILE
end
