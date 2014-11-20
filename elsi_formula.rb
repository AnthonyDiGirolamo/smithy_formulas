class ElsiFormula < Formula
  homepage "https://github.com/DanielWherry/elsi"
  url "https://github.com/DanielWherry/elsi/archive/v3.14.tar.gz"

  module_commands do 
  end

  def install
    module_list
    system "make elsi.titan.exe"
    system "make install PREFIX="+prefix
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
    prepend-path MANPATH         $PREFIX/man
  MODULEFILE
end
