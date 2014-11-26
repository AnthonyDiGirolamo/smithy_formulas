class FileutilsFormula < Formula
  homepage "https://github.com/hpc"
  url "http://users.nccs.gov/~fwang2/fileutils-0.0.1.tar.gz"

  depends_on ["dtcmp"]
  modules [ "libarchive", "attr", "lwgrp", "dtcmp", "libcircle", "PrgEnv-gnu", "openmpi", "automake113" ]

  def install
    module_list
    system "./autogen.sh"
    system "CFLAGS=\"-DDCOPY_USE_XATTRS\" CC=mpicc ./configure --prefix=#{prefix} --with-libdtcmp=#{dtcmp.prefix}"
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

    module load openmpi
    module load lwgrp
    module load dtcmp
    module load libcircle

    prepend-path PATH            $PREFIX/bin
    prepend-path INCLUDE_PATH    $PREFIX/include
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
  modulefile
end
