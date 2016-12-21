class LammpsFormula < Formula
  homepage "http://lammps.sandia.gov/"
  url "none"

  # Recent Changes Page: http://lammps.sandia.gov/bug.html
  # See https://github.com/lammps/lammps/commits/master for svn version numbers
  concern for_version("13Oct2015") do
    included do
      params svn_url: "svn://svn.icms.temple.edu/lammps-ro/trunk@14112"
    end
  end

  concern for_version("15May2015") do
    included do
      params svn_url: "svn://svn.icms.temple.edu/lammps-ro/trunk@13475"
    end
  end

  concern for_version("30Apr2015") do
    included do
      params svn_url: "svn://svn.icms.temple.edu/lammps-ro/trunk@13450"
    end
  end

  concern for_version("06Mar2015") do
    #Release date: 6 Mar 2015
    included do
      params svn_url: "svn://svn.icms.temple.edu/lammps-ro/trunk@13216"
    end
  end

  concern for_version("20Jan2015") do
    #Release date: 20 Jan 2015
    included do
       params svn_url: "svn://svn.icms.temple.edu/lammps-ro/trunk@12958"

    end
  end

  concern for_version("10Feb15") do
    # 10 Feb 2015 = stable version, SVN rev = 13095
    included do
      params svn_url: "svn://svn.lammps.org/lammps-ro/trunk@13095"
    end
  end

  concern for_version("15May15") do
    # Patched version
    # See ticket https://rt.ccs.ornl.gov/Ticket/Display.html?id=254892
    included do
      params svn_url: "svn://svn.lammps.org/lammps-ro/trunk@13475"
    end
  end

  concern for_version("16Feb16") do
    included do
      params svn_url: "svn://svn.lammps.org/lammps-ro/trunk@14624"
    end
  end

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
      commands << "load gcc"
    when /cray/
      commands << "load #{pe}cray"
      commands << "swap cce cce/#{$1}" if build_name =~ /cray([\d\.]+)/
    end

    commands << "load subversion"
    commands << "load fftw"
    commands << "load python/2.7.9"
    commands << "load cudatoolkit" if module_is_available?("cudatoolkit")
    commands
  end

  depends_on do
    [ "python/2.7.9" ]
  end

  def install
    module_list
     system "svn co #{svn_url} source" unless Dir.exists?("source")


    Dir.chdir prefix+"/source"

    h = `hostname`
    args = ""
    if h.to_s =~ /"titan"/
      h = h.to_s.split('-')[0]
      system "svn revert src/MAKE/MACHINES/Makefile.jaguar"
      system "sed 's/CCFLAGS =/CCFLAGS = -O2 -ftree-vectorize -Wl,-Bdynamic -L\\/sw\\/xc30\\/python\\/2.7.9\\/sles11.3_gnu4.8.2\\/lib/' src/MAKE/MACHINES/Makefile.jaguar > src/MAKE/MACHINES/Makefile.#{h}"
      system "sed -i 's/LINKFLAGS =/LINKFLAGS = -O2 -ftree-vectorize -Wl,-Bdynamic -L\\/sw\\/xc30\\/python\\/2.7.9\\/sles11.3_gnu4.8.2\\/lib/' src/MAKE/MACHINES/Makefile.#{h}"

      Dir.chdir prefix + "/source/lib/gpu"
      system "make -j8 -f Makefile.xk7 clean"
      system "make -j8 -f Makefile.xk7"
    
      Dir.chdir prefix + "/source/lib/reax"
      system "sed 's/ gfortran/ftn/g' Makefile.gfortran > Makefile.cray"
      system "make -f Makefile.cray clean"
      system "make -f Makefile.cray"

      Dir.chdir prefix + "/source/lib/meam"
      system "sed 's/ gfortran/ftn/g' Makefile.gfortran > Makefile.cray"
      system "make -f Makefile.cray clean"
      system "make -f Makefile.cray"
      args = "yes-std no-kim yes-meam no-poems yes-gpu yes-reax no-kokkos no-voronoi yes-kspace yes-molecule yes-rigid yes-colloid yes-manybody yes-misc"
    else
      h = h.to_s.split('-')[0]
      system "svn revert src/MAKE/Makefile.mpi"
      system "sed 's/CCFLAGS =/CCFLAGS = -g -O3 -DLAMMPS_MEMALIGN=64/' src/MAKE/Makefile.mpi > src/MAKE/MACHINES/Makefile.#{h}"
      system "sed -i 's/LINKFLAGS =/LINKFLAGS = -g -O /' src/MAKE/MACHINES/Makefile.#{h}"
      system "sed -i 's/LINK =.*/LINK = CC/' src/MAKE/MACHINES/Makefile.#{h}"
      system "sed -i 's/CC =.*/CC = CC/' src/MAKE/MACHINES/Makefile.#{h}"
      args = "yes-user-intel no-kim no-meam no-poems no-gpu no-reax no-kokkos no-voronoi yes-kspace yes-molecule yes-rigid yes-colloid yes-manybody yes-misc"
    end


    Dir.chdir prefix + "/source/src"
    system "make no-all clean-all"
    system "make #{args}"
    system "make #{h}"

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
