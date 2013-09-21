class LammpsFormula < Formula

  # LAMMPS 19Sep13 svn revision 10814 as per svn command below
   
  homepage "http://lammps.sandia.gov/"
  url "none"

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    case build_name
    when /gnu/
      commands << "load #{pe}gnu"
      commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
    when /pgi/
      commands << "load #{pe}pgi"
      commands << "swap pgi pgi/#{$1}" if build_name =~ /pgi([\d\.]+)/
    when /intel/
      commands << "load #{pe}intel"
      commands << "swap intel intel/#{$1}" if build_name =~ /intel([\d\.]+)/
    when /cray/
      commands << "load #{pe}cray"
      commands << "swap cce cce/#{$1}" if build_name =~ /cray([\d\.]+)/
    end

    commands << "load subversion"
    commands << "load fftw"
    commands << "load cudatoolkit" if module_is_available?("cudatoolkit")
    commands
  end

  def install
    module_list

    system "svn co svn://svn.icms.temple.edu/lammps-ro/trunk@10814 source" unless Dir.exists?("source")

    Dir.chdir prefix+"/source"
    system "svn revert src/MAKE/Makefile.jaguar"
    system "sed 's/CCFLAGS/CCFLAGS = -O2 -march=bdver1 -ftree-vectorize/' src/MAKE/Makefile.jaguar > src/MAKE/Makefile.titan"
    system "sed -i 's/LINKFLAGS/LINKFLAGS = -O2 -march=bdver1 -ftree-vectorize/' src/MAKE/Makefile.titan"
    system "sed -i 's/NODE_PARTITION/LAMMPS_JPEG/g' src/MAKE/Makefile.titan"
    system "sed -i 's/JPG_LIB =/JPG_LIB = -ljpeg/' src/MAKE/Makefile.titan"
    system "sed -i 's/CXX/CC/g' src/MAKE/Makefile.titan"

    Dir.chdir prefix + "/source/lib/reax"
    system "sed 's/ gfortran/ftn/g' Makefile.gfortran > Makefile.cray"

    Dir.chdir prefix + "/source/lib/meam"
    system "sed 's/ gfortran/ftn/g' Makefile.gfortran > Makefile.cray"
    
    # File.open("src/MAKE/Makefile.titan", "w+") do |file|
    #   file.write <<-EOF.strip_heredoc
    #     test
    #   EOF
    # end

    Dir.chdir prefix + "/source/lib/gpu"
    system "make -j8 -f Makefile.xk7 clean"
    system "make -j8 -f Makefile.xk7" if module_is_available?("cudatoolkit")

    Dir.chdir prefix + "/source/lib/reax"
    system "make -f Makefile.cray clean"
    system "make -f Makefile.cray"

    Dir.chdir prefix + "/source/lib/meam"
    system "make -f Makefile.cray clean"
    system "make -f Makefile.cray"
    
    Dir.chdir prefix + "/source/src"
    system "make no-all clean-all"
    system "make yes-asphere yes-body yes-class2 yes-colloid yes-dipole yes-fld"
    system "make yes-granular yes-kspace yes-manybody yes-mc yes-meam yes-misc"
    system "make yes-molecule yes-opt yes-reax yes-replica yes-rigid yes-shock"
    system "make yes-srd yes-user-cg-cmm yes-user-misc"
    system "make yes-gpu" if module_is_available?("cudatoolkit")
    system "make -j8 titan"

    system "mkdir -p #{prefix}/bin"
    system "cp #{prefix}/source/src/lmp_* #{prefix}/bin/"
  end

  modulefile <<-EOF.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr "-----------------------------------------------------------"
       puts stderr "- Executable is lmp_titan"
       puts stderr "- Built with asphere, body, class2, colloid, dipole, fld, "
       puts stderr "-   granula, kspace, manybody, mc, meam, misc, molecule, "
       puts stderr "-   opt, reax, replica, rigid, shock, srd, user-cg-cmm, "
       puts stderr "-   user-misc packages."
       puts stderr "- Build with gpu package on supported systems "
       puts stderr "-----------------------------------------------------------"
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    prereq PrgEnv-gnu

    set PREFIX <%= @package.prefix %>

    prepend-path PATH            $PREFIX/bin
  EOF
end
