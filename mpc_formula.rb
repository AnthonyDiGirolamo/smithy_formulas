class MpcFormula < Formula
  homepage "http://www.multiprecision.org/index.php?prog=mpc"
  url "ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz"
  sha1 "b8be66396c726fdc36ebb0f692ed8a8cca3bcc66"

  module_commands ["unload PrgEnv-pgi PrgEnv-intel PrgEnv-gnu PE-pgi PE-intel PE-gnu","load PrgEnv-gnu"]
  depends_on ["gmp","mpfr"]

  def install
    module_list
    system "./configure --prefix=#{prefix} --with-gmp=#{gmp.prefix} --with-mpfr=#{mpfr.prefix}"
    system "make install"
    system "ln -s #{prefix}/lib/libmpc.so.3 #{prefix}/lib/libmpc.so.2"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    prepend-path LD_LIBRARY_PATH  $PREFIX/lib
  MODULEFILE
end
