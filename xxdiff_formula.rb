class XxdiffFormula < Formula
  homepage "http://downloads.sourceforge.net/"
  url "http://downloads.sourceforge.net/project/xxdiff/xxdiff/4.0/xxdiff-4.0.tar.bz2"
  sha256 "91501544e82bc89983d07eeb086419645fbfa78fc906b50ff7ab6cdf39431330"

  def install
    module_list
    system "python setup.py build"
    system "python setup.py install --prefix=#{prefix}"
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
