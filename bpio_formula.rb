class BpioFormula < Formula
  homepage "http://github.com/ORNL-TechInt/bpio"
  url "http://users.nccs.gov/~fwang2/bpio-v0.3-10-gc2da266.tar.gz"

  def install
    module_list
    system "./configure --prefix=#{prefix} --target=cray"
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
    prepend-path PATH            $PREFIX/bin
    prepend-path INCLUDE_PATH    $PREFIX/include
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path PIO_CONFIG_PATH $PREFIX/share
  MODULEFILE
end
