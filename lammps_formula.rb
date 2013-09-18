class LammpsFormula < Formula
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

    system "svn co svn://svn.icms.temple.edu/lammps-ro/trunk@10802 source" unless Dir.exists?("source")
    Dir.chdir prefix+"/source"

    system "svn revert src/MAKE/Makefile.jaguar"
    system "sed 's/CCFLAGS/CCFLAGS = -O2 -march=bdver1 -ftree-vectorize/' src/MAKE/Makefile.jaguar > src/MAKE/Makefile.titan"
    system "sed -i 's/LINKFLAGS/LINKFLAGS = -O2 -march=bdver1 -ftree-vectorize/' src/MAKE/Makefile.titan"

    # File.open("src/MAKE/Makefile.titan", "w+") do |file|
    #   file.write <<-EOF.strip_heredoc
    #     test
    #   EOF
    # end

    Dir.chdir prefix + "/source/lib/gpu"
    system "make -j8 -f Makefile.xk7 clean"
    system "make -j8 -f Makefile.xk7"

    Dir.chdir prefix + "/source/src"
    system "make no-all clean-all"
    system "make yes-gpu yes-kspace"
    system "make -j8 titan"

    system "mkdir -p #{prefix}/bin"
    system "cp #{prefix}/source/src/lmp_* #{prefix}/bin/"
  end

  modulefile <<-EOF.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    prereq PrgEnv-gnu
    prereq fftw

    set PREFIX <%= @package.prefix %>

    prepend-path PATH            $PREFIX/bin
  EOF
end
