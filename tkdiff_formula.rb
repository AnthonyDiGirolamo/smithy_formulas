class TkdiffFormula < Formula
  homepage "http://downloads.sourceforge.net/"
  url "http://downloads.sourceforge.net/project/tkdiff/tkdiff/4.2/tkdiff-4.2.tar.gz"
  sha256 "734bb417184c10072eb64e8d274245338e41b7fdeff661b5ef30e89f3e3aa357"

  def install
    module_list
    system "mkdir -p #{prefix}/bin"
    system "cp tkdiff #{prefix}/bin"
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
