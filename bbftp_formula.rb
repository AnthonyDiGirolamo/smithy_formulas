class BbftpFormula < Formula
  homepage "http://doc.in2p3.fr/bbftp/"
  url "http://doc.in2p3.fr/bbftp/dist/bbftp-client-3.2.1.tar.gz"
  md5 "8aacf78dddc6ccaf66931038d7d4b6cd"

  def install
    Dir.chdir "bbftpc"
    system "./configure --prefix=#{prefix}"
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
