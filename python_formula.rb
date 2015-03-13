class PythonFormula < Formula
  homepage "www.python.org/"

  depends_on "sqlite"

  module_commands ["unload python"]

  concern :Version2_7_9 do
    included do
      url "https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz"
      md5 "5eebcaa0030dc4061156d3429657fb83"
    end
  end

  concern :Version3_4_3 do
    included do
      url "https://www.python.org/ftp/python/3.4.3/Python-3.4.3.tgz"
      md5 "4281ff86778db65892c05151d5de738d"
    end
  end

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
    prepend-path PYTHONPATH      $PREFIX/lib/python2.7/site-packages
  MODULEFILE
end
