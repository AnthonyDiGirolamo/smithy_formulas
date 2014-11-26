class LibtoolFormula < Formula
  homepage "http://www.gnu.org/software/libtool/"
  url "http://ftpmirror.gnu.org/libtool/libtool-2.4.2.tar.gz"
  version "2.4.2"

  module_commands = [ "purge" ]

  def install
    module_list
    ENV['CC'] = "gcc"
    ENV['CXX'] = "g++"
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

    setenv LIBTOOL_DIR $PREFIX
    setenv LIBTOOL_INC "-I$PREFIX/include"
    setenv LIBTOOL_LIB "-L$PREFIX/lib"

    prepend-path PATH            $PREFIX/bin
    prepend-path LIBRARY_PATH    $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path MANPATH         $PREFIX/share/man
  MODULEFILE
end
