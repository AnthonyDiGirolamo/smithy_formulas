class VmdFormula < Formula
  homepage "http://www.ks.uiuc.edu/Research/vmd/doxygen/index.html"
  url "none"

  #-----------------------------------------------------
  # Commnads to have the correct programming           -
  # environment.                                        -
  #                                                    -
  #-----------------------------------------------------
  module_commands [
      "unload PE-pgi PE-intel PE-gnu",
      "load PE-gnu",
      "load netcdf/4.1.3",
      "load tcl/8.5.15"
  ]

  depends_on ["mesa", "openbabel", "xmgr", "stride", "surf", "fltk", "netcdf/4.1.3", "tachyon/0.98.9", "tcl/8.5.15"]

  def install
    module_list

    #-----------------------------------------------------
    # Get the starting directory of the install method.  -
    #                                                    -
    #-----------------------------------------------------
    starting_directory = Dir.getwd()
    print "The starting directory is #{ starting_directory }\n"
    
    #-----------------------------------------------------
    # Define the location of the netcdf base directory   -
    # directory.                                         -
    #                                                    -
    # Define the path to the NETCDF headers and          -
    # libraries                                          -
    #-----------------------------------------------------
    netcdfbasedir = module_environment_variable("netcdf/4.1.3","NETCDF_DIR")

    ENV['NETCDFLIB'] =  "-L#{netcdfbasedir}/lib"
    system "echo NETCDFLIB is ${NETCDFLIB}\n"

    ENV["NETCDFINC"]  = "-I#{netcdfbasedir}/include"
    system "echo NETCDFINC is ${NETCDFINC}\n"

    #-----------------------------------------------------
    # Define the location of the vmd install base        -
    # directory. The location should be writable by the  -
    # installer.                                         -
    #-----------------------------------------------------
    ENV['VMD_BASE_DIR'] = "#{prefix}/source/vmd_installation_dir"
    system "echo VMD_BASE_DIR is ${VMD_BASE_DIR}"

    #-----------------------------------------------------
    # Define the location of the vmd plugin dir          -
    # directory.                                         -
    #-----------------------------------------------------
    ENV['PLUGINDIR'] = "#{prefix}/source/vmd_installation_dir/plugins"
    system "echo PLUGINDIR  is ${PLUGINDIR}"

    #-----------------------------------------------------
    # Define the location to install the vmd binary.     -
    #                                                    -
    #-----------------------------------------------------
    ENV['VMDINSTALLBINDIR'] = "#{prefix}/source/vmd_installation_dir/bin"
    system "echo VMDINSTALLBINDIR  is ${VMDINSTALLBINDIR}"

    #-----------------------------------------------------
    # Define the vmd install name.                       -
    #                                                    -
    #-----------------------------------------------------
    ENV['VMDINSTALLNAME'] =  "vmd"
    system "echo VMDINSTALLNAME is ${VMDINSTALLNAME}"

    #-----------------------------------------------------
    # Define the location to install the vmd library.    -
    #                                                    -
    #-----------------------------------------------------
    ENV['VMDINSTALLLIBRARYDIR'] =  "#{prefix}/source/vmd_installation_dir/lib"
    system "echo VMDINSTALLLIBRARYDIR  is ${VMDINSTALLLIBRARYDIR}"

    #-----------------------------------------------------
    # Define the location to the fltk binary.            -
    #                                                    -
    #-----------------------------------------------------
    fltkbasedir = fltk.prefix
    print "fltkbasedir is #{fltkbasedir}\n"

    #-----------------------------------------------------
    # Define the location to the surf binary.            -
    #                                                    -
    #-----------------------------------------------------
    surfbasedir = surf.prefix
    print "surfbasedir is #{surfbasedir}\n"

    #-----------------------------------------------------
    # Define the location of the tachyon library.        -
    #                                                    -
    #-----------------------------------------------------
    tachyonbasedir = tachyon.prefix
    print "tachyonbasedir is #{ tachyon.prefix }\n"

    #-----------------------------------------------------
    # Define the location of the stride library.         -
    #                                                    -
    #-----------------------------------------------------
    stridebasedir = stride.prefix
    print "stridebasedir is #{ stride.prefix }\n"

    #-----------------------------------------------------
    # Define the  variables.                             -
    #                                                    -
    #-----------------------------------------------------
    mesabasedir = mesa.prefix
    print "mesa base dir = #{ mesabasedir }\n"

    #-----------------------------------------------------
    # Commands to build the plugins library.             -
    #                                                    -
    #-----------------------------------------------------

    tclinc = module_environment_variable("tcl/8.5.15","TCLINC")
    tcllib = module_environment_variable("tcl/8.5.15","TCLLIB")

    Dir.chdir("#{prefix}/source/plugins")
    puts Dir.pwd
    system "gmake"
    system "gmake clean"
    system "gmake LINUXAMD64 TCLINC=#{tclinc} TCLLIB=#{tcllib}"
    system "gmake distrib"

    #-----------------------------------------------------
    # Commands to link the surf binary.                  -
    #                                                    -
    #-----------------------------------------------------
    Dir.chdir("#{starting_directory}/source/vmd-1.9.1/lib/surf")
    puts Dir.pwd
    system "ln -f -s #{surf.prefix}/surf ./surf_LINUXAMD64" 

    #-----------------------------------------------------
    # Commands to link the stride binary.                -
    #                                                    -
    #-----------------------------------------------------
    Dir.chdir("#{starting_directory}/source/vmd-1.9.1/lib/stride")
    puts Dir.pwd
    system "ln -f -s #{stride.prefix}/stride ./stride_LINUXAMD64" 

    #-----------------------------------------------------
    # Commands to link the tachyon binary.               -
    #                                                    -
    #-----------------------------------------------------
    Dir.chdir("#{starting_directory}/source/vmd-1.9.1/lib/tachyon")
    system "ln -f -s #{tachyon.prefix}/source/compile/linux-64/tachyon ./tachyon_LINUXAMD64" 
    puts Dir.pwd

    # Part of link line  -L../lib/fltk/LINUXAMD64 
    # -I../lib/fltk/include
    #
    #Dir.chdir("#{starting_directory}/source/vmd-1.9.1/lib/fltk")
    #puts Dir.pwd
    #-#system "mkdir -p LINUXAMD"
    #-#system "cp -rf #{fltk.prefix}/lib/* LINUXAMD/" 

    #-#system "mkdir -p include"
    #-#system "cp -rf #{fltk.prefix}/include/FL include/" 

    #system "ln -f -s #{fltk.prefix}/bin bin" 
    #system "ln -f -s #{fltk.prefix}/share share" 

    #-#Dir.chdir("#{starting_directory}/source/vmd-1.9.1/lib")
    #-#puts Dir.pwd
    #-#system "cp -rf  #{tachyon.prefix}/source/compile/linux-mpi/* tachyon/" 
    #-#system "cp tachyon/tachyon tachyon/tachyon_LINUXAMD64" 

    Dir.chdir("#{prefix}/source/vmd-1.9.1")
    system "rm -rf plugins"
    system "cp -rf #{prefix}/source/vmd_installation_dir/plugins plugins "
    system "./configure LINUXAMD64 OPENGL FLTK TK TCL NETCDF" 
    Dir.chdir("#{prefix}/source/vmd-1.9.1/src")
    system "make clean"
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
        puts stderr "Sets up environment to use the vmd software tool."
        puts stderr "Note that this software is untested and may not work properly. "
      }
      module-whatis "<%= @package.name %> <%= @package.version %>"
      module load netcdf/4.1.3
      prepend-path PATH <%= @package.prefix %>/source/vmd_installation_dir/bin
      prepend-path LD_LIBRARY_PATH <%= @package.prefix %>/source/vmd_installation_dir/lib
  EOF
end
