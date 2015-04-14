class Hdf5Formula < Formula
  homepage "http://www.hdfgroup.org/"
  url "http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.11/src/hdf5-1.8.11.tar.bz2"
  md5 "3433c1be767d2b8e5b0771a3209b4fcc"

  depends_on "szip"

  #module_commands do
  #  pe = "PE-"
  #  pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

  #  commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
  #  case build_name
  #  when /gnu/
  #    commands << "load #{pe}gnu"
  #    commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
  #  when /pgi/
  #    commands << "load #{pe}pgi"
  #    commands << "swap pgi pgi/#{$1}" if build_name =~ /pgi([\d\.]+)/
  #  when /intel/
  #    commands << "load #{pe}intel"
  #    commands << "swap intel intel/#{$1}" if build_name =~ /intel([\d\.]+)/
  #  when /cray/
  #    commands << "load #{pe}cray"
  #    commands << "swap cce cce/#{$1}" if build_name =~ /cray([\d\.]+)/
  #  end

  #  commands << "load szip"
  #  commands << "swap xtpe-interlagos xtpe-istanbul" if pe == "PrgEnv-"
  #  commands
  #end

  module_commands do
    commands = [ "purge" ]
    case build_name
    when /gnu/
     commands << "load gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
    when /pgi/
      commands << "load pgi/#{$1}" if build_name =~ /pgi([\d\.]+)/
    when /intel/
      commands << "load intel/#{$1}" if build_name =~ /intel([\d\.]+)/
    when /cray/
      commands << "load cce/#{$1}" if build_name =~ /cray([\d\.]+)/
    end
    commands << "load openmpi/1.8.2"
    commands << "load szip"
    commands
  end


  def install
    module_list

    case build_name
    when /gnu/
      ENV["CC"]  = "gcc"
      ENV["CXX"] = "g++"
      ENV["F77"] = "gfortran"
      ENV["FC"]  = "gfortran"
      ENV["F9X"] = "gfortran"
    when /pgi/
      ENV["CC"]  = "pgcc"
      ENV["CXX"] = "pgCC"
      ENV["F77"] = "pgf77"
      ENV["FC"]  = "pgf90"
      ENV["F9X"]  = "pgf90"
    when /intel/
      ENV["CC"]  = "icc"
      ENV["CXX"] = "icpc"
      ENV["F77"] = "ifort"
      ENV["FC"]  = "ifort"
      ENV["F9X"]  = "ifort"
    when /cray/
      ENV["CC"]  = "cc --target=native"
      ENV["CXX"] = "CC --target=native"
      ENV["F77"] = "ftn --target=native"
      ENV["FC"]  = "ftn --target=native"
      ENV["F9X"] = "ftn --target=native"
    end

    args = [
      "./configure --prefix=#{prefix}",
      "--with-zlib=/usr",
      "--with-szlib=$SZIP_DIR",
      "--enable-fortran",
      "--enable-cxx" #, "--enable-shared"#, "--enable-static"
    ]

    if build_name.include? "fortran2003"
      args << "--enable-fortran2003"
    elsif build_name.include? "nofortran"
      args.delete_if {|option| option == "--enable-fortran"}
    end

    if name.include? "parallel"
      args << "--enable-parallel"
      args.delete("--enable-cxx")

      if module_is_available?("PE-gnu")
        ENV["CC"]  = "mpicc"
        ENV["CXX"] = "mpiCC"
        ENV["F77"] = "mpif77"
        ENV["FC"]  = "mpif90"
        ENV["F9X"] = "mpif90"
        system "which mpicc"
      else
        ENV["CC"]  = "cc"
        ENV["CXX"] = "CC"
        ENV["F77"] = "ftn"
        ENV["FC"]  = "ftn"
        ENV["F9X"] = "ftn"
        args << "--enable-static"
        args << "--disable-shared"
        args[0] = "XTPE_LINK_TYPE=dynamic LD_LIBRARY_PATH=/usr/lib/alps:$LD_LIBRARY_PATH ./configure --prefix=#{prefix}"
      end
    end

    system args
    system "make"
    system "make install"
  end

  modulefile do
    <<-MODULEFILE.strip_heredoc
      #%Module
      proc ModulesHelp { } {
        puts stderr {Sets up environment to use serial HDF5.

      Usage: ftn test.f90 \${HDF5_LIB} OR h5fc test.f90
      or     cc  test.c   \${HDF5_LIB} OR h5cc test.c

      The hdf5 module must be reloaded if you change the PrgEnv
      or you must issue a 'module update' command.

      **Note** Requires szip/2.1

      Loading the module:
        module load szip/2.1
        module load <%= @package.name %>/<%= @package.version %>}
      }
      # One line description
      module-whatis "<%= @package.name %> <%= @package.version %>"

      module load szip/2.1
      prereq szip/2.1
      set szipdir $::env(SZIP_DIR)

      <% if @builds.size > 1 %>
      <%= module_build_list @package, @builds, :prgenv_prefix => #{module_is_available?("PrgEnv-gnu") ? '"PrgEnv-"' : '"PE-"'} %>

      set PREFIX <%= @package.version_directory %>/$BUILD
      <% else %>
      set PREFIX <%= @package.prefix %>
      <% end %>

      setenv HDF5_INCLUDE_PATH "-I$PREFIX/include"
      setenv HDF5_LIB "-L$PREFIX/lib -lhdf5_hl -lhdf5 -L$szipdir -lsz -lz -lm"
      setenv HDF5_DIR "${PREFIX}"

      prepend-path PATH             $PREFIX/bin
      prepend-path LD_LIBRARY_PATH  $PREFIX/lib
      prepend-path LIBRARY_PATH     $PREFIX/lib
      prepend-path INCLUDE_PATH     $PREFIX/include
    MODULEFILE
  end
end
