class LuaFormula < Formula
  # 5.2 is not fully backwards compatible, and breaks e.g. luarocks.
  # It is available in Homebrew-versions for the time being.
  homepage 'http://www.lua.org/'
  url 'http://www.lua.org/ftp/lua-5.1.5.tar.gz'
  sha1 'b3882111ad02ecc6b972f8c1241647905cb2e3fc'

  module_commands [ "purge" ]

  def install
    module_list

    patch <<-EOF.strip_heredoc
      diff --git a/Makefile b/Makefile
      index 209a132..e437306 100644
      --- a/Makefile
      +++ b/Makefile
      @@ -9,7 +9,7 @@ PLAT= none

       # Where to install. The installation starts in the src and doc directories,
       # so take care if INSTALL_TOP is not an absolute path.
      -INSTALL_TOP= /usr/local
      +INSTALL_TOP= #{prefix}
       INSTALL_BIN= $(INSTALL_TOP)/bin
       INSTALL_INC= $(INSTALL_TOP)/include
       INSTALL_LIB= $(INSTALL_TOP)/lib
    EOF

    system "make linux"
    system "make install"

    Dir.chdir prefix
    system "mkdir -p lib/pkgconfig"
    system "cp source/etc/lua.pc lib/pkgconfig"
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
    prepend-path MANPATH         $PREFIX/man
  MODULEFILE
end

