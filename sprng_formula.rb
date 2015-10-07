class SprngFormula < Formula
  homepage "http://www.sprng.org/"
  url "http://www.sprng.org/Version2.0/sprng2.0b.tar.gz"
  version "2.0b"


  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    case build_name
    when /gnu/
      commands << "load #{pe}gnu"
      commands << "swap #{pe}gnu #{pe}gnu/#{$1}" if build_name =~ /gnu([\d\.]+)/
    when /pgi/
      commands << "load #{pe}pgi"
      commands << "swap #{pe}pgi #{pe}pgi/#{$1}" if build_name =~ /pgi([\d\.]+)/
    when /intel/
      commands << "load #{pe}intel"
      commands << "swap #{pe}intel #{pe}intel/#{$1}" if build_name =~ /intel([\d\.]+)/
    end

    commands
  end

  def install
    module_list

    case Smithy::Config.arch
    when /xk/, /xc/
        case build_name
        when /pgi/
          ENV["CC"]  = "pgcc"
          ENV["CXX"] = "pgCC"
          ENV["F77"] = "pgf77"
          ENV["FC"]  = "pgf90"
          ffxn="-DAdd_"
        when /gnu/, /gcc/
          ENV["CC"]  = "gcc"
          ENV["CXX"] = "g++"
          ENV["F77"] = "gfortran"
          ENV["FC"]  = "gfortran"
          ffxn="-DAdd_"
        when /intel/
          ENV["CC"]  = "icc"
          ENV["CXX"] = "icpc"
          ENV["F77"] = "ifort"
          ENV["FC"]  = "ifort"
          ffxn="-DAdd__"
        when /cray/
          ENV["CC"]  = "cc"
          ENV["CXX"] = "CC"
          ENV["F77"] = "ftn"
          ENV["FC"]  = "ftn"
          ffxn="-DUpCase"
        end
        File.open("make.CHOICES", "w+") do |file|
            file.write <<-EOF.strip_heredoc
              PLAT = OLCFCRAY
              MPIDEF = -DSPRNG_MPI
              LIB_REL_DIR = lib
            EOF
        end
    else
        ENV["CC"]  = "mpicc"
        ENV["CXX"] = "mpic++"
        ENV["F77"] = "mpif77"
        ENV["FC"]  = "mpif90"
        ENV["F9X"] = "mpif90"
        File.open("make.CHOICES", "w+") do |file|
            file.write <<-EOF.strip_heredoc
              PLAT = OLCFINTEL
              MPIDEF = -DSPRNG_MPI
              LIB_REL_DIR = lib
            EOF
        end
    end

    File.open("SRC/make.OLCFINTEL", "w+") do |file|
        file.write <<-EOF.strip_heredoc
          AR = ar
          ARFLAGS = cr
          #If your system does not have ranlib, then replace next statement with
          #RANLIB = echo
          RANLIB = ranlib
          CC = mpicc
          CLD = $(CC)
          # Set f77 to echo if you do not have a FORTRAN compiler
          F77 = mpif77
          #F77 = echo
          F77LD = $(F77)
          FFXN = -DAdd__
          FSUFFIX = F

          MPIF77 = mpif77
          MPICC = mpicc

          # To use MPI, set the MPIDIR to location of mpi library, and MPILIB
          # to name of mpi library. Remove # signs from beginning of next 3 lines.
          # Also, if the previous compilation was without MPI, type: make realclean
          # before compiling for mpi.
          #
          # COMMENTED BY ME
          #MPIDIR = -L/usr/local/mpi/build/LINUX/ch_p4/lib
          #MPILIB = -lmpich

          # Please include mpi header file path, if needed

          #CFLAGS = -O3 -DLittleEndian $(PMLCGDEF) $(MPIDEF) -D$(PLAT)  -I/usr/local/mpi/include -I/usr/local/mpi/build/LINUX/ch_p4/include
          CFLAGS = -O3 -DLittleEndian $(PMLCGDEF) $(MPIDEF) -D$(PLAT)
          CLDFLAGS =  -O3
          #FFLAGS = -O3 $(PMLCGDEF) $(MPIDEF) -D$(PLAT)  -I/usr/local/mpi/include -I/usr/local/mpi/build/LINUX/ch_p4/include -I.
          FFLAGS = -O3 $(PMLCGDEF) $(MPIDEF) -D$(PLAT)
          F77LDFLAGS =  -O3

          CPP = cpp -P
        EOF
    end

    File.open("SRC/make.OLCFCRAY", "w+") do |file|
        file.write <<-EOF.strip_heredoc
          AR = ar
          ARFLAGS = cr
          #If your system does not have ranlib, then replace next statement with
          #RANLIB = echo
          RANLIB = ranlib
          CC = cc
          CLD = cc
          # Set f77 to echo if you do not have a FORTRAN compiler
          F77 = ftn
          #F77 = echo
          F77LD = ftn
          FFXN = #{ffxn}
          FSUFFIX = F

          MPIF77 = ftn
          MPICC = cc

          # To use MPI, set the MPIDIR to location of mpi library, and MPILIB
          # to name of mpi library. Remove # signs from beginning of next 3 lines.
          # Also, if the previous compilation was without MPI, type: make realclean
          # before compiling for mpi.
          #
          # COMMENTED BY ME
          #MPIDIR = -L/usr/local/mpi/build/LINUX/ch_p4/lib
          #MPILIB = -lmpich

          # Please include mpi header file path, if needed

          #CFLAGS = -O3 -DLittleEndian $(PMLCGDEF) $(MPIDEF) -D$(PLAT)  -I/usr/local/mpi/include -I/usr/local/mpi/build/LINUX/ch_p4/include
          CFLAGS = -O3 -DLittleEndian $(PMLCGDEF) $(MPIDEF) -D$(PLAT)
          CLDFLAGS =  -O3
          #FFLAGS = -O3 $(PMLCGDEF) $(MPIDEF) -D$(PLAT)  -I/usr/local/mpi/include -I/usr/local/mpi/build/LINUX/ch_p4/include -I.
          FFLAGS = -O3 $(PMLCGDEF) $(MPIDEF) -D$(PLAT)
          F77LDFLAGS =  -O3

          CPP = cpp -P
        EOF
    end


    # system "./configure --prefix=#{prefix} FFLAGS=-fsecond-underscore"
    system "make all"

    Dir.chdir prefix
    FileUtils.mkdir_p "lib"
    system "cp -rf source/include ./"
    system "cp -rf source/lib/libsprng.a lib/"
    system "cp -rf source/lib/libsprngtest.a lib/"
  end

  modulefile do
    <<-MODULEFILE.strip_heredoc
      #%Module
      proc ModulesHelp { } {
        puts stderr {Sets up environment to use SPRNG.

      Usage:
        mpicc code.c $SPRNG_LIB
        cc code.c $SPRNG_LIB

      The sprng module must be reloaded if you change the PrgEnv
      or you must issue a 'module update' command.

      Loading the module:
        module load <%= @package.name %>/<%= @package.version %>}
      }
      # One line description
      module-whatis "<%= @package.name %> <%= @package.version %>"

      <% if @builds.size > 1 %>
      <%= module_build_list @package, @builds, :prgenv_prefix => #{module_is_available?("PrgEnv-gnu") ? '"PrgEnv-"' : '"PE-"'} %>

      set PREFIX <%= @package.version_directory %>/$BUILD
      <% else %>
      set PREFIX <%= @package.prefix %>
      <% end %>

      setenv SPRNG_DIR $PREFIX
      setenv SPRNG_INC "-I$PREFIX/include"
      setenv SPRNG_LIB "-I$PREFIX/include\ -L$PREFIX/lib\ -lsprng"
    MODULEFILE
  end
end
