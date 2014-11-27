class DtcmpFormula < Formula
  homepage "https://github.com/hpc"
  url "http://users.nccs.gov/~fwang2/dtcmp-1.0.1.tar.gz"

  module_commands [ "load ompi" ]
  module_commands [ "load lwgrp"]
  def install
    module_list
    system "./configure --prefix=#{prefix} --with-lwgrp=$LWGRP"
    system "make"
    system "make install"
  end

  modulefile <<-modulefile.strip_heredoc
    #%Module
    proc moduleshelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # one line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>
    
    prepend-path DTCMP           $PREFIX
    prepend-path PATH            $PREFIX/bin
    prepend-path INCLUDE_PATH    $PREFIX/include
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
  modulefile
end
