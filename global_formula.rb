class GlobalFormula < Formula
  homepage "http://tamacom.com/global"
  url      "http://tamacom.com/global/global-6.3.4.tar.gz"
  sha1     "6b73c0b3c7eea025c8004f8d82d836f2021d0c9e"

  def install
    ENV["CC"] = "gcc"
    module_list
    system "which gcc"
    system "./configure CFLAGS=\"-O3\" --prefix=#{prefix} --with-exuberant-ctags=/usr/bin/ctags"
    system "make"
    system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr "<%= @package.name %> - print locations of given symbols"
       puts stderr ""
       puts stderr "Global  finds  locations  of given symbols in C, C++, Yacc, Java, PHP and Assembly source files,"
       puts stderr "and prints the path name, line number and line image of the locations.  Global  can  locate  not"
       puts stderr "only definitions but also references and other symbols."
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib/gtags
    prepend-path MANPATH         $PREFIX/share/man
  MODULEFILE
end
