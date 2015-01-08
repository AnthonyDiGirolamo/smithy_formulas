class ZeromqFormula < Formula
  homepage "http://download.zeromq.org"
  url      "http://download.zeromq.org/zeromq-4.0.5.tar.gz"

  def install
    ENV["CC"] = "gcc"
    module_list
    system "which gcc"
    system "./configure --prefix=#{prefix}"
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

    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path MANPATH         $PREFIX/share/man
  MODULEFILE
end
