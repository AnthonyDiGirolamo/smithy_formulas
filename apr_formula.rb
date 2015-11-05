class AprFormula < Formula
  homepage "https://apr.apache.org/"
  url "http://apache.spinellicreations.com//apr/apr-1.4.6.tar.bz2"
  md5 "ffee70a111fd07372982b0550bbb14b7"

  version "1.4.6"

  def install
    module_list
    system "./configure --prefix=#{prefix} --enable-shared --disable-static --disable-debug"
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
