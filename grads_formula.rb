class GradsFormula < Formula
  homepage "http://www.iges.org/grads/"
  url "ftp://cola.gmu.edu/grads/2.0/grads-2.0.2-src.tar.gz"

  depends_on ["libgd"]

  module_commands ["purge"]

  def install
    module_list
    system "which gcc && gcc --version"
    system "LDFLAGS='-L#{libgd.prefix}/lib' CPPFLAGS='-I#{libgd.prefix}/include' ./configure --prefix=#{prefix} --with-printim"
    system "make"
    system "make install"
  end

  modulefile do
    <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LD_LIBRARY_PATH #{libgd.prefix}/lib
    setenv       GADDIR          $PREFIX/data
    MODULEFILE
  end
end
