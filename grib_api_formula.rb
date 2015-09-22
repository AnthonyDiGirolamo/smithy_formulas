class GribApiFormula < Formula
  homepage "https://software.ecmwf.int/wiki/display/GRIB/Home"
  url "https://software.ecmwf.int/wiki/download/attachments/3473437/grib_api-1.14.0-Source.tar.gz?api=v2"
  sha256 "67a4d8d059994e325aa4b74cfab84f4c7050c42b030b9ba40493b9c487d0972d"

  def install
    module_list
    system "./configure --prefix=#{prefix}"
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

    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    setenv GRIB_API_LIB          "-L$PREFIX/lib"
    setenv GRIB_API_INC          "-L$PREFIX/include"
    prepend-path MANPATH         $PREFIX/share/man
  MODULEFILE
end
