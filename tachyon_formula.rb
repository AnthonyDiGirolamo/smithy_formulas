class TachyonFormula < Formula
  homepage "http://jedi.ks.uiuc.edu/~johns/raytracer/"
  url "http://jedi.ks.uiuc.edu/~johns/raytracer/files/0.98.9/tachyon-0.98.9.tar.gz"

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
    system "pwd && ls"
    system "cd unix && make linux-64"
  end

  #-----------------------------------------------------
  # Template for module file.                          -
  #                                                    -
  #-----------------------------------------------------
  modulefile <<-EOF.strip_heredoc
      #%Module
      proc ModulesHelp { } {
        puts stderr "<%= @package.name %> <%= @package.version %>"
        puts stderr "Sets up environment to use tachyon."
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

      setenv TACHYON_DIR $PREFIX/source
      prepend-path LD_LIBRARY_PATH $PREFIX/source/compile/linux-64
      prepend-path CPATH $PREFIX/source/src
      prepend-path CPLUS_INCLUDE_PATH $PREFIX/source/src
      prepend-path C_INCLUDE_PATH $PREFIX/source/src
  EOF
end
