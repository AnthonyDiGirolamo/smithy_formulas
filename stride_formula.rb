class StrideFormula < Formula
  homepage "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC441567/"
  url "ftp://ftp.ebi.ac.uk/pub/software/unix/stride/src/stride.tar.gz"

  module_commands do
  [
      "unload PE-pgi PE-intel PE-gnu",
      "load PE-gnu"
  ] end

  def install
    #-----------------------------------------------------
    # Commnads to have the correct module environment.   -
    #                                                    -
    #-----------------------------------------------------
    module_list

    #-----------------------------------------------------
    # Commands to build the library.                     -
    #                                                    -
    #-----------------------------------------------------
    system "make"
    system "cp ./stride #{prefix}"
  end

  #-----------------------------------------------------
  # Template for module file.                          -
  #                                                    -
  #-----------------------------------------------------
  modulefile <<-EOF.strip_heredoc
      #%Module
      proc ModulesHelp { } {
        puts stderr "<%= @package.name %> <%= @package.version %>"
        puts stderr "Sets up environment to use the Stride software tool."
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

      setenv STRIDE_DIR $PREFIX
  EOF

end
