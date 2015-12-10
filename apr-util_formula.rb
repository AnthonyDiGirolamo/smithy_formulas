class AprUtilFormula < Formula
  homepage "https://apr.apache.org/"
  url "http://apache.spinellicreations.com//apr/apr-util-1.5.1.tar.bz2"
  md5 "9c1db8606e520f201c451ec9a0b095f6"

  version "1.5.1"

  depends_on "apr"

  def install
    module_list
    system "./configure --prefix=#{prefix} --enable-shared --disable-static --disable-debug --with-apr=#{apr.prefix}"
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
