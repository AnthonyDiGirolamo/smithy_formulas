class EmacsFormula < Formula
  homepage "https://www.gnu.org/software/emacs/"
  url "http://ftpmirror.gnu.org/emacs/emacs-24.3.tar.gz"
  md5 "d20441025efd4931ef64cc2bb18eddc9"

  module_commands ["purge"]

  def install
    module_list

    system "./configure",
      "--prefix=#{prefix}",
      "--with-x-toolkit=lucid",
      "--with-gif=no",
      "--enable-locallisppath=#{prefix}/share/emacs/site-lisp"

    system "make"
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
    prepend-path INFOPATH  $PREFIX/info
  MODULEFILE
end
