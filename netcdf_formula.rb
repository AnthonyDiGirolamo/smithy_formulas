class NetcdfFormula < Formula
  homepage "http://www.unidata.ucar.edu/software/netcdf/"
  url "https://github.com/Unidata/netcdf-c/archive/v4.3.3.1.tar.gz"

  depends_on ["hdf5/1.8.11", "szip/2.1"]

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
    commands << "load szip"
    commands << "load hdf5/1.8.11"
    commands << "swap xtpe-interlagos xtpe-istanbul" if pe == "PrgEnv-"
    commands
  end

  def install
    raise "You must specify a version" if version == "none"
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
      ENV["FC"]  = "pgf90"
      ENV["F90"]  = "pgf90"
    when /intel/
      ENV["CC"]  = "icc"
      ENV["CXX"] = "icpc"
      ENV["F77"] = "ifort"
      ENV["FC"]  = "ifort"
      ENV["F9X"]  = "ifort"
    # when /cray/
    #   ENV["CC"]  = "cc --target=native"
    #   ENV["CXX"] = "CC --target=native"
    #   ENV["F77"] = "ftn --target=native"
    #   ENV["FC"]  = "ftn --target=native"
    #   ENV["F9X"] = "ftn --target=native"
    end

    ENV["CPPFLAGS"] = "-I#{hdf5.prefix}/include -I#{szip.prefix}/include"
    ENV["LDFLAGS"]  = "-L#{hdf5.prefix}/lib     -L#{szip.prefix}/lib -lhdf5 -lhdf5_hl -lsz -lz -lm"

    system "echo $CPPFLAGS"
    system "echo $LDFLAGS"
    system "./configure --prefix=#{prefix}",
#      "--enable-shared",
#      "--enable-static",
#      "--enable-fortran",
      "--with-gnu-ld"
    system "make"
    system "make install"

#    Dir.chdir("..")
#    FileUtils.rm_rf temp_dir_name
  end

  modulefile do
    <<-MODULEFILE.strip_heredoc
    #%Module

    proc ModulesHelp { } {
       puts stderr "Sets up environment to use netcdf <%= @package.version %>"
       puts stderr "Usage:   fortrancompiler test.f90 \${NETCDF_FLIB}"
       puts stderr "    or   ccompiler test.c \${NETCDF_CLIB}"
    }
    module-whatis "Sets up environment to use netcdf <%= @package.version %>"

    module unload hdf5
    module unload szip

    module load szip/2.1
    prereq szip/2.1

    module load hdf5/1.8.11
    prereq hdf5/1.8.11

    <% if @builds.size > 1 %>
    <%= module_build_list @package, @builds, :prgenv_prefix => #{module_is_available?("PrgEnv-gnu") ? '"PrgEnv-"' : '"PE-"'} %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    <% else %>
    set PREFIX <%= @package.prefix %>
    <% end %>

    set MOD_INCLUDE "-module . -module $PREFIX/include"

    prepend-path PATH $PREFIX/bin

    set NETCDF_F_INCLUDE_PATH   "$MOD_INCLUDE -I$PREFIX/include"
    set NETCDF_C_INCLUDE_PATH   "-I$PREFIX/include"
    set NETCDF_CPP_INCLUDE_PATH "-I$PREFIX/include"

    set NETCDF_LD_OPTS     "-L$PREFIX/lib -lnetcdff -lnetcdf_c++ -lnetcdf -L\\$HDF5_DIR/lib -lhdf5_hl -lhdf5 -L\\$SZIP_DIR/lib -lsz -lz -lm -lcurl"
    set NETCDF_C_LD_OPTS   "-L$PREFIX/lib -lnetcdf -L\\$HDF5_DIR/lib -lhdf5_hl -lhdf5 -L\\$SZIP_DIR/lib -lsz -lz -lm -lcurl"
    set NETCDF_CPP_LD_OPTS "-L$PREFIX/lib -lnetcdf_c++ -lnetcdf -L\\$HDF5_DIR/lib -lhdf5_hl -lhdf5 -L\\$SZIP_DIR/lib -lsz -lz -lm -lcurl"
    set NETCDF_F_LD_OPTS   "-L$PREFIX/lib -lnetcdff -lnetcdf -L\\$HDF5_DIR/lib -lhdf5_hl -lhdf5 -L\\$SZIP_DIR/lib -lsz -lz -lm -lcurl"

    setenv NETCDF_CLIB   "$NETCDF_C_INCLUDE_PATH $NETCDF_C_LD_OPTS"
    setenv NETCDF_CPPLIB "$NETCDF_C_INCLUDE_PATH $NETCDF_CPP_LD_OPTS"
    setenv NETCDF_FLIB   "$NETCDF_F_INCLUDE_PATH $NETCDF_F_LD_OPTS"

    setenv NETCDF_DIR "${PREFIX}"

    prepend-path PATH             $PREFIX/bin
    prepend-path LD_LIBRARY_PATH  $PREFIX/lib
    prepend-path LIBRARY_PATH     $PREFIX/lib
    prepend-path INCLUDE_PATH     $PREFIX/include
    prepend-path MANPATH          $PREFIX/share/man
    MODULEFILE
  end
end
