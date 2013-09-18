class Netcdf413Formula < Formula
  homepage "http://www.unidata.ucar.edu/software/netcdf/"
  url "http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-4.1.3.tar.gz"

  depends_on do
    case build_name
    when /gnu/
      compiler = "gnu"
    when /pgi/
      compiler = "pgi12"
    when /intel/
      compiler = "intel"
    when /cray/
      compiler = "cray"
    end
    [ "hdf5/1.8.11/*#{compiler}*", "szip/*/*#{compiler}*" ]
  end

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    m = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    case build_name
    when /gnu/
      m << "load #{pe}gnu"
    when /pgi/
      m << "load #{pe}pgi"
    when /intel/
      m << "load #{pe}intel"
    when /cray/
      m << "load #{pe}cray"
    end
    m << "load szip"
    m << "load /sw/xk6/modulefiles/hdf5/1.8.11"
    m << "swap xtpe-interlagos xtpe-istanbul"
    m
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
      "--disable-shared",
      "--enable-static",
      "--enable-fortran",
      "--enable-cxx"
    system "make"
    system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module

    proc ModulesHelp { } {
       puts stderr "Sets up environment to use netcdf 4.1.3"
       puts stderr "Usage:   ftn test.f90 \${NETCDF_FLIB}"
       puts stderr "    or   cc test.c \${NETCDF_CLIB}"
       puts stderr "To see the compilation options, try: "
       puts stderr "% nc-config --all"
       puts stderr "
        Note modules szip/2.1 and hdf5/1.8.7 are required

        Available PE: pgi/11.8.0 and pgi/11.9.0
            Not available yet for intel, gnu and pathscale.

        Loading the module:

            % module swap pgi \[pgi/11.8.0 | pgi/11.9.0\]
            % module load szip/2.1
            % module load hdf/1.8.7
            % module load netcdf/4.1.3"
    }
    module-whatis "Sets up environment to use netcdf 4.1.3"

    prereq szip/2.1
    prereq hdf5/1.8.7

    <% if @builds.size > 1 %>
    <%= module_build_list @package, @builds %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    <% else %>
    set PREFIX <%= @package.prefix %>
    <% end %>

    set MOD_INCLUDE "-module . -module $PREFIX/include"

    prepend-path PATH $PREFIX/bin

    set NETCDF_F_INCLUDE_PATH "$MOD_INCLUDE -I$PREFIX/include"
    set NETCDF_C_INCLUDE_PATH "-I$PREFIX/include"
    set NETCDF_LD_OPTS "-L$PREFIX/lib -lnetcdf "
    setenv NETCDF_CLIB "$NETCDF_C_INCLUDE_PATH $NETCDF_LD_OPTS"
    setenv NETCDF_FLIB "$NETCDF_F_INCLUDE_PATH $NETCDF_LD_OPTS"
    setenv NETCDF_DIR "${PREFIX}"

    set sys [ uname machine ]

    prepend-path PATH             $PREFIX/bin
    prepend-path LD_LIBRARY_PATH  $PREFIX/lib
    prepend-path LIBRARY_PATH     $PREFIX/lib
    prepend-path INCLUDE_PATH     $PREFIX/include
    prepend-path MANPATH          $PREFIX/share/man
  MODULEFILE
end
