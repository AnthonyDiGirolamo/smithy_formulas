class LibffiFormula < Formula
  homepage "http://sourceware.org/libffi/"
  url "ftp://sourceware.org/pub/libffi/libffi-3.1.tar.gz"

  def install
    module_list
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"
  end

  modulefile <<-modulefile.strip_heredoc
    #%Module
    proc moduleshelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # one line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>
    set PKGNAME <%= @package.name %>-<%= @package.version %>
    
    prepend-path PATH            $PREFIX/bin
    prepend-path INCLUDE_PATH    $PREFIX/lib/$PKGNAME/include
    prepend-path LD_LIBRARY_PATH $PREFIX/lib64
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
  modulefile
end
