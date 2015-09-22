class MesaFormula < Formula
  homepage "www.mesa3d.org"
  url "ftp://ftp.freedesktop.org/pub/mesa/10.5.4/mesa-10.5.4.tar.gz"

  #-----------------------------------------------------
  # Commnads to have the correct module environment.   -
  #                                                    -
  #-----------------------------------------------------
  module_commands do
  [
      "unload PE-pgi PE-intel PE-gnu",
      "load PE-gnu"
  ] end

  def install
    module_list

    #-----------------------------------------------------
    # Commands to build the library.                     -
    #                                                    -
    #-----------------------------------------------------
    system "./configure --prefix=#{prefix} --without-gallium-drivers --disable-dri --enable-xlib-glx --enable-osmesa"
    system "make"
    system "make install"
  end 

  #-----------------------------------------------------
  # Template for module file.                          -
  #                                                    -
  #-----------------------------------------------------
  modulefile <<-EOF.strip_heredoc
      #%Module
      proc ModulesHelp { } {
        puts stderr "<%= @package.name %> <%= @package.version %>"
        puts stderr "Sets up environment to use the Mesa graphics library."
        puts stderr "Note that this software is untested and may not work properly. "
      }
      module-whatis "<%= @package.name %> <%= @package.version %>"

      <% if @builds.size > 1 %>
      <%= module_build_list @package, @builds %>

  
      #-----------------------------------------------------
      # Mesa top level install directory.                  -
      #                                                    -
      #-----------------------------------------------------
      set PREFIX <%= @package.version_directory %>/$BUILD
      <% else %>
      set PREFIX <%= @package.prefix %>
      <% end %>

      setenv MESA_DIR $PREFIX
      setenv OSMESA_ROOT $PREFIX
      prepend-path LD_LIBRARY_PATH $PREFIX/lib
      prepend-path CPATH $PREFIX/include
      prepend-path CPLUS_INCLUDE_PATH $PREFIX/include
      prepend-path C_INCLUDE_PATH $PREFIX/include
      prepend-path MESA_INCLUDE -I$PREFIX/include
      prepend-path MESA_LIB -L$PREFIX/lib/
      prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
  EOF
end
