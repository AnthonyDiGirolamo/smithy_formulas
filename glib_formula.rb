class GlibFormula < Formula
  homepage "https://developer.gnome.org/glib/stable"
  url "http://ftp.gnome.org/pub/gnome/sources/glib/2.36/glib-2.36.4.tar.xz"

  module_commands [ "load libffi" ]
  module_commands [ "load automake113" ]
  #module_commands [ "load autoconf" ]
  #module_commands [ "load automake" ]

  def install
    module_list
    #system "./autogen.sh"
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

    module load libffi
    prereq libffi

    set PREFIX <%= @package.prefix %>

    prepend-path PATH            $PREFIX/bin
    prepend-path INCLUDE_PATH    $PREFIX/include/glib-2.0
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
  modulefile
end
