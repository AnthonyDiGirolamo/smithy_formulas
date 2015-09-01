class NetcdfFormula < Formula
  homepage "http://www.unidata.ucar.edu/software/netcdf/"

  concern for_version("4.3.3.1") do
    included do
      url "https://github.com/Unidata/netcdf-c/archive/v4.3.3.1.tar.gz"

      params f_source_url: "ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.4.2.tar.gz",
             cpp_source_url: "https://github.com/Unidata/netcdf-cxx4/archive/v4.2.1.tar.gz"
    end
  end

  concern for_version("4.2.0") do
    included do
      url "ftp://ftp.unidata.ucar.edu/pub/netcdf/old/netcdf-4.2.0.tar.gz"
    end
  end

  depends_on do
    deps = ["hdf5/1.8.11", "szip/2.1"]
    case build_name
    when /gnu/
      deps = [ "hdf5/1.8.11/*gnu*", "szip/2.1/*gnu*" ]
    when /pgi/
      deps = [ "hdf5/1.8.11/*pgi*", "szip/2.1/*pgi*" ]
    when /intel/
      deps = [ "hdf5/1.8.11/*intel*", "szip/2.1/*intel*" ]
    end
    deps
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
    prgenv = :native
    case build_name
    when /gnu/
      prgenv = :gnu
      ENV["CC"]  = "gcc"
      ENV["CXX"] = "g++"
      ENV["F77"] = "gfortran"
      ENV["FC"]  = "gfortran"
      ENV["F9X"] = "gfortran"
    when /pgi/
      prgenv = :pgi
      ENV["CC"]  = "pgcc"
      ENV["CXX"] = "pgCC"
      ENV["FC"]  = "pgf90"
      ENV["F90"]  = "pgf90"
    when /intel/
      prgenv = :intel
      ENV["CC"]  = "icc"
      ENV["CXX"] = "icpc"
      ENV["F77"] = "ifort"
      ENV["FC"]  = "ifort"
      ENV["F9X"]  = "ifort"
    end

    c_config_options = ["--prefix=#{prefix}"]
    f_config_options = ["--prefix=#{prefix}"]
    cpp_config_options = ["--prefix=#{prefix}", "--enable-cxx-4"]

    if prgenv == :native
      c_config_options << "--host=x86_64-unknown-linux-gnu"
      f_config_options << "--host=x86_64-unknown-linux-gnu"
      cpp_config_options << "--host=x86_64-unknown-linux-gnu"
    else
      # Intentionally blank for now.
    end

    # Install the base package.
    ENV["CPPFLAGS"] = "-I#{hdf5.prefix}/include -I#{szip.prefix}/include"
    ENV["LDFLAGS"]  = "-L#{hdf5.prefix}/lib     -L#{szip.prefix}/lib -lhdf5 -lhdf5_hl -lsz -lz -lm"
    system "echo $CPPFLAGS"
    system "echo $LDFLAGS"

    system "./configure " + c_config_options.join(" ")
    system "make check"
    system "make install"

    # Setup the environment variable strings needed to build fortran and cpp
    # libs without the base module being installed.
    ENV["CPPFLAGS"] = "-I#{prefix}/include -I#{hdf5.prefix}/include -I#{szip.prefix}/include"
    ENV["LDFLAGS"] = "-L#{prefix}/lib -L#{hdf5.prefix}/lib -L#{szip.prefix}/lib"
    ENV["LIBS"] = "-lnetcdf -lhdf5_hl -lhdf5 -lz -lcurl"
    system "echo $CPPFLAGS"
    system "echo $LDFLAGS"

    build_env = "export PATH=#{prefix}/bin:$PATH; "\
                "export LD_LIBRARY_PATH=#{prefix}/lib:/#{hdf5.prefix}/lib:/#{szip.prefix}/lib:$LD_LIBRARY_PATH; "

    if defined?(f_source_url)
      src_dir = "netcdf_f_src"
      FileUtils.rm_rf src_dir
      FileUtils.mkdir_p src_dir
      tarfile = File.basename("#{f_source_url}")
      system "wget #{f_source_url}" unless File.exists?(tarfile)
      system "tar -xf #{tarfile} -C #{src_dir} --strip-components=1"
      Dir.chdir src_dir do |dirname|
        system build_env + " ./configure " + f_config_options.join(" ")
        system build_env + " make check"
        system build_env + " make install"
      end
      FileUtils.rm tarfile
    end

    if defined?(cpp_source_url)
      src_dir = "netcdf_cpp_src"
      FileUtils.rm_rf src_dir
      FileUtils.mkdir_p src_dir
      tarfile = File.basename("#{cpp_source_url}")
      system ["wget", "#{cpp_source_url}"] unless File.exists?(tarfile)
      system "tar -xf #{tarfile} -C #{src_dir} --strip-components=1"
      Dir.chdir src_dir do |dirname|
        system build_env + " ./configure " + cpp_config_options.join(" ")
        system build_env + " make check"
        system build_env + " make install"
      end
      FileUtils.rm tarfile
    end
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
