class VimFormula < Formula
  homepage "http://www.vim.org"
  url "http://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2"
  sha1 '601abf7cc2b5ab186f40d8790e542f86afca86b7'

  module_commands ["purge"]

  def install
    module_list
    system "./configure --prefix=#{prefix} --with-features=huge"
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
  MODULEFILE
end
