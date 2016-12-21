class OsmesaFormula < Formula
  homepage "http://www.mesa3d.org"
  url "ftp://ftp.freedesktop.org/pub/mesa/11.2.1/mesa-11.2.1.tar.xz"

  module_commands [
    "purge",
    "load PrgEnv-gnu",
    "load python"
  ]

  def install
    module_list
    system "./configure --disable-xvmc --disable-glx --disable-dri --with-dri-drivers= --with-gallium-drivers=swrast --enable-texture-float --disable-egl --with-egl-platforms= --enable-gallium-osmesa --enable-gallium-llvm=yes --prefix=#{prefix}"
    system "make"
    system "make install"
  end

  modulefile do
  <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    prepend-path PATH $PREFIX/bin
    prepend-path OSMESA_LIBRARY_PATH $PREFIX/lib64
  MODULEFILE
  end
end
