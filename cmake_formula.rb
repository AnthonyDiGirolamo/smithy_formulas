class CmakeFormula < Formula
  homepage "http://www.cmake.org/"
  url      "http://www.cmake.org/files/v2.8/cmake-2.8.11.2.tar.gz"

  module_commands [ "purge" ]

  def install
    module_list
    system "./bootstrap --prefix=#{prefix} --no-qt-gui"
    system "make all"
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
    
    prepend-path PATH      $PREFIX/bin
    prepend-path MANPATH   $PREFIX/share/man
  MODULEFILE
end
