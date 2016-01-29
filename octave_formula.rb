class OctaveFormula < Formula
  homepage "https://ftp.gnu.org/"
  url "https://ftp.gnu.org/gnu/octave/octave-4.0.0.tar.xz"
  md5 "f3de0a0d9758e112f13ce1f5eaf791bf"

  module_commands [ "unload PrgEnv-cray PrgEnv-gnu PrgEnv-intel PrgEnv-pathscale PrgEnv-pgi", "load PrgEnv-gnu", "load pcre", "load cray-libsci" ]

  def install
    module_list
    system "CPPFLAGS=`pcre-config --cflags` LDFLAGS=`pcre-config --libs` ./configure --prefix=#{prefix}  --with-blas=$CRAY_LIBSCI_PREFIX_DIR/lib/libsci_gnu.a"
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

    prepend-path PATH             $PREFIX/bin
    prepend-path LD_LIBRARY_PATH  $PREFIX/lib/octave-4.0.0
    prepend-path MANPATH          $PREFIX/share/man
  MODULEFILE
end
