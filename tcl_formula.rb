class TclFormula < Formula
  homepage "http://www.tcl.tk"
  url "http://prdownloads.sourceforge.net/tcl/tcl8.5.15-src.tar.gz"

  #-----------------------------------------------------
  # Commnads to have the correct programming           -
  # environment.                                       -
  #                                                    -
  #-----------------------------------------------------
  module_commands [
      "unload PE-pgi PE-intel PE-gnu",
      "load PE-gnu",
      "load netcdf/4.1.3"
  ]

  def install
    module_list
    #-----------------------------------------------------
    # Get the starting directory of the install method.  -
    #                                                    -
    #-----------------------------------------------------
    starting_directory = Dir.getwd()
    print "The starting directory is #{ starting_directory }\n"
    
    Dir.chdir("#{prefix}/source/unix")
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"

    Dir.chdir("#{starting_directory}")
    puts Dir.pwd
  end
  
  #-----------------------------------------------------
  # Template for module file.                          -
  #                                                    -
  #-----------------------------------------------------
  modulefile <<-EOF.strip_heredoc
      #%Module
      proc ModulesHelp { } {
        puts stderr "<%= @package.name %> <%= @package.version %>"
        puts stderr "Sets up environment to use the TCL tool kit.
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

      prepend-path PATH  $PREFIX/bin
      prepend-path LD_LIBRARY_PATH $PREFIX/lib
      prepend-path CPATH $PREFIX/include
      prepend-path CPLUS_INCLUDE_PATH $PREFIX/include
      prepend-path C_INCLUDE_PATH $PREFIX/include
      prepend-path TCLINC -I$PREFIX/include
      prepend-path TCLLIB -L$PREFIX/lib/
      prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
      prepend-path MANPATH $PREFIX/share/man
  EOF
end
