class Python3Formula < Formula
  homepage "www.python.org/"
  url "http://www.python.org/ftp/python/3.3.2/Python-3.3.2.tar.bz2"

  depends_on "sqlite"

  def install
    module_list

    ENV["CPPFLAGS"] = "-I#{sqlite.prefix}/include"
    ENV["LDFLAGS"]  = "-L#{sqlite.prefix}/lib"

    system "./configure --prefix=#{prefix} --enable-shared"
    system "make"
    system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
    prepend-path PYTHONPATH      $PREFIX/lib/python3.3/site-packages
  MODULEFILE
end
