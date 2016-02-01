class NeditFormula < Formula
  homepage "http://downloads.sourceforge.net/"
  url "http://downloads.sourceforge.net/project/nedit/nedit-source/nedit-5.6a-src.tar.gz"

  def install
    module_list
    system "make linux"
    system "mkdir -p ../bin"
    system "cp ../source/source/nc ../bin"
    system "cp ../source/source/nedit ../bin"
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
  MODULEFILE
end
