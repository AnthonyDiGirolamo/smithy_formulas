class SurfFormula < Formula
  homepage "http://www.ks.uiuc.edu/Research/vmd/doxygen/extprogs.html"
  url "http://www.ks.uiuc.edu/Research/vmd/extsrcs/surf.tar.Z"

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
    system "wget #{url}"
    system "gunzip surf.tar.Z"
    system "tar xf surf.tar"
    system "make depend"
    system "make surf"
    system "cp ./surf #{prefix}"

  end

  #-----------------------------------------------------
  # Template for module file.                          -
  #                                                    -
  #-----------------------------------------------------
  modulefile <<-EOF.strip_heredoc
      #%Module
      proc ModulesHelp { } {
        puts stderr "<%= @package.name %> <%= @package.version %>"
        puts stderr "Sets up environment to use the Surf software tool."
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

      setenv SURF_DIR $PREFIX
  EOF

end
