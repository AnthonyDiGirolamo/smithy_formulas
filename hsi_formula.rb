class HsiFormula < Formula
  homepage "http://www.mgleicher.us/index.html/hsi/"
  url "none"

  def install
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX /sw/sources/hpss

    prepend-path PATH      $PREFIX/bin
    prepend-path MANPATH   $PREFIX/man
  MODULEFILE
end
