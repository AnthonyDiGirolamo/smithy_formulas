class OpenbabelFormula < Formula
  homepage "http://openbabel.org/wiki/Main_Page"
  url "none"

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
    system "mkdir -p source && cd source && wget -O - http://sourceforge.net/projects/openbabel/files/openbabel/2.3.2/openbabel-2.3.2.tar.gz/download > openbabel-2.3.2.tar.gz && tar xf openbabel-2.3.2.tar.gz  && mkdir -p build && cd build && cmake ../openbabel-2.3.2 -DCMAKE_INSTALL_PREFIX=#{prefix} && make -j2 && make install"
  end

  #-----------------------------------------------------
  # Template for module file.                          -
  #                                                    -
  #-----------------------------------------------------
  modulefile <<-EOF.strip_heredoc
      #%Module
      proc ModulesHelp { } {
        puts stderr "<%= @package.name %> <%= @package.version %>"
        puts stderr "Sets up environment to use Babel."
        puts stderr "Note that this software is untested and may not work properly. "
      }
      module-whatis "<%= @package.name %> <%= @package.version %>"

      <% if @builds.size > 1 %>
      <%= module_build_list @package, @builds %>

  
      #-----------------------------------------------------
      # Babel top level install directory.                 -
      #                                                    -
      #-----------------------------------------------------
      set PREFIX <%= @package.version_directory %>/$BUILD
      <% else %>
      set PREFIX <%= @package.prefix %>
      <% end %>

      setenv BABEL_DIR $PREFIX
      setenv BABEL_BIN $PREFIX/bin/babel
      prepend-path LD_LIBRARY_PATH $PREFIX/lib
      prepend-path CPATH $PREFIX/include
      prepend-path CPLUS_INCLUDE_PATH $PREFIX/include
      prepend-path C_INCLUDE_PATH $PREFIX/include
      prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
  EOF

end
