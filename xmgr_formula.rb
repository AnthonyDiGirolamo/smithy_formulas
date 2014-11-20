class XmgrFormula < Formula
  homepage "http://plasma-gate.weizmann.ac.il/Xmgr/"
  url "ftp://plasma-gate.weizmann.ac.il/pub/xmgr4/src/xmgr-4.1.2.tar.gz"

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
    system "./configure --prefix=#{prefix} --enable-acegr-home=#{prefix}"
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
        puts stderr "Sets up environment to use xmgr."
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

      setenv XMGR_DIR $PREFIX
  EOF
end
