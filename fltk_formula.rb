class FltkFormula < Formula
  homepage "www.fltk.org"
  url "http://fltk.org/pub/fltk/1.3.2/fltk-1.3.2-source.tar.gz"

  #-----------------------------------------------------
  # commnads to have the correct module environment.   -
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
    system "make clean"
    system "./configure --prefix=#{prefix}"
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
        puts stderr "Sets up environment to use the FLTK tool kit.
      }
      module-whatis "<%= @package.name %> <%= @package.version %>"

      <% if @builds.size > 1 %>
      <%= module_build_list @package, @builds %>

  
      #-----------------------------------------------------
      # FLTK top level install directory.                  -
      #                                                    -
      #-----------------------------------------------------
      set PREFIX <%= @package.version_directory %>/$BUILD
      <% else %>
      set PREFIX <%= @package.prefix %>
      <% end %>

      setenv FLTK_DIR $PREFIX
      prepend-path LD_LIBRARY_PATH $PREFIX/lib
      prepend-path CPATH $PREFIX/include
      prepend-path CPLUS_INCLUDE_PATH $PREFIX/include
      prepend-path C_INCLUDE_PATH $PREFIX/include
      prepend-path FLTK_INCLUDE -I$PREFIX/include
      prepend-path FLTK_LIB -L$PREFIX/lib/
      prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
      prepend-path MANPATH $PREFIX/share/man
  EOF
end
