class PdtoolkitFormula < Formula
  homepage "http://www.cs.uoregon.edu/research/pdt/"
  url "http://tau.uoregon.edu/pdt.tgz"
  version "3.19"

  module_commands ["purge"]

  def install
    module_list
    system "./configure -prefix=#{prefix} -GNU"
    system "make clean all"
    system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set ARCH x86_64
    set PREFIX <%= @package.prefix %>

    setenv PDTOOLKIT_DIR $PREFIX
    setenv PDTOOLKIT_INC $PREFIX/include
    setenv PDTOOLKIT_LIB $PREFIX/$ARCH/lib

    prepend-path PATH            $PREFIX/$ARCH/bin
    prepend-path LIBRARY_PATH    $PREFIX/$ARCH/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/$ARCH/lib
  MODULEFILE
end
