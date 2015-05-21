class AdiosFormula < Formula
  homepage "https://www.olcf.ornl.gov/center-projects/adios/"
  url      "http://users.nccs.gov/~pnorbert/adios-1.8.0.tar.gz"
  sha1     "8b84026f5c7d4f6b65cbe414d5f8738cfc5beafc" 

  #depends_on [ "mxml/2.9" ] # This is not enough to load the correct compiler version

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    commands = [ "unload szip" ]
    commands << "unload hdf5 hdf5-parallel cray-hdf5 cray-hdf5-parallel"
    commands << "unload netcdf netcdf-parallel cray-netcdf cray-netcdf-parallel"
    commands << "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" 

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
    commands << "swap craype-interlagos craype-istanbul" if pe == "PrgEnv-"
    
    # Load modules if we need the path to the shared libraries
    if module_is_available?("fastbit") && module_is_available?("PrgEnv-gnu")
        commands << "load fastbit"
    end
    #puts "#{commands}"
    commands
  end


  def install

    confopts="" 
    #
    # Common options
    #
    if module_is_available?("mxml/2.9")
        mxml_prefix = module_environment_variable("mxml/2.9", "MXML_DIR")
        confopts << " --with-mxml=#{mxml_prefix}"
    else
        raise "ADIOS #{version} requires mxml/2.9"
    end

    #
    # Options for Cray CLEs
    # 
    if build_name.include?("cle")

      ENV["CPPFLAGS"] = "-DMPICH_IGNORE_CXX_SEEK -DDART_DO_VERSIONING"
      ENV["CFLAGS"]   = "-fPIC -g"
      ENV["CC"]       = "cc"
      ENV["CXX"]      = "CC"
      ENV["FC"]       = "ftn"

      # add gnu C++ library to link flags to support C++ dependencies (fastbit, nssi) 
      default_gcc_path = module_environment_variable("gcc", "GCC_PATH")
      default_gcc_libstdcxx = "#{default_gcc_path}/snos/lib64/libstdc++.a"
      ENV["EXTRA_LIBS"] = "#{default_gcc_libstdcxx}"
      #puts "C++ library: #{default_gcc_libstdcxx}"

      case build_name
      when /gnu/
        rca_opts = module_environment_variable("rca", "CRAY_RCA_POST_LINK_OPTS")
        ENV["LDFLAGS"] = "#{rca_opts}"
      when /pgi/
        ENV["LDFLAGS"] = "-pgcpplibs"
        confopts << " --disable-timers"
      when /intel/
        ENV["LDFLAGS"] = ""
      when /cray/
        raise "Cray build of ADIOS is not supported. Use the GNU build."
      end

      confopts << " --enable-dependency-tracking \
      --with-cray-pmi=/opt/cray/pmi/default \
      --with-cray-ugni-incdir=/opt/cray/gni-headers/default/include \
      --with-cray-ugni-libdir=/opt/cray/ugni/default/lib64 \
      --with-lustre"
      #--with-szip=#{SZIP_DIR} \
      #--with-isobar=#{prefix}"

      if module_is_available?("cray-hdf5")
          seq_hdf5_prefix = module_environment_variable("cray-hdf5", "HDF5_DIR")
          seq_hdf5_libs = `PKG_CONFIG_PATH=#{seq_hdf5_prefix}/lib/pkgconfig; pkg-config --libs --static hdf5_hl`
          seq_hdf5_libs.delete!("\n")
          confopts << " --with-hdf5=#{seq_hdf5_prefix} --with-hdf5-libs=\"#{seq_hdf5_libs}\""

          if module_is_available?("cray-netcdf")
            seq_nc_prefix = module_environment_variable("cray-netcdf", "NETCDF_DIR")
            seq_nc_libs = `PKG_CONFIG_PATH=#{seq_nc_prefix}/lib/pkgconfig:#{seq_hdf5_prefix}/lib/pkgconfig; pkg-config --libs --static netcdf`
            seq_nc_libs.delete!("\n")
            confopts << " --with-netcdf=#{seq_nc_prefix} --with-netcdf-libs=\"#{seq_nc_libs}\""
          end

      end


      ## This does not work because pkg_config --static fails for this package
      #if module_is_available?("cray-hdf5-parallel")
      #    par_hdf5_prefix = module_environment_variable("cray-hdf5-parallel", "HDF5_DIR")
      #    par_hdf5_libs = `PKG_CONFIG_PATH=$PKG_CONFIG_PATH:#{par_hdf5_prefix}/lib/pkgconfig; pkg-config --libs --static hdf5_parallel`
      #    confopts << " --with-phdf5=#{par_hdf5_prefix} --with-hdf5-libs=\"#{par_hdf5_libs}\""
      #end

    #
    # Options for RedHat6 clusters
    # 
    elsif build_name.include?("rhel6")

      ENV["CFLAGS"]  = "-fPIC -g"
      ENV["CC"]  = "mpicc"
      ENV["CXX"] = "mpicxx"
      ENV["FC"]  = "mpif90"
      #confopts << " --this-is-not-working-yet"
    else
      raise "Unsupported build system (#{build_name})"
    end

    #
    # Common options
    #
    if module_is_available?("dataspaces/1.5.0")
        dataspaces_prefix = module_environment_variable("dataspaces/1.5.0", "DATASPACES_DIR")
        confopts << " --with-dataspaces=#{dataspaces_prefix} --with-dimes=#{dataspaces_prefix}"
    end
    #if module_is_available?("fastbit")
    #    fastbit_prefix = module_environment_variable("fastbit", "FASTBIT_DIR")
    #    confopts << " --with-fastbit=#{fastbit_prefix}"
    #end
    confopts << " --with-zlib"

    ENV["CFLAGS"]  = "-fPIC"

    module_list

    system "./configure --prefix=#{prefix} #{confopts}"
    system "make -j 8"
    system "make install"

    Dir.chdir prefix
    `mkdir -p etc`
    #`cat etc/adios_config.flags | grep "=" | sed -e "s/\([^=]*\)=\(.*\)/set \1 \2/" > etc/adios_config.tcl`
    `cat etc/adios_config.flags | grep "=" | sed -e "s/\\([^=]*\\)=\\(.*\\)/set \\1 \\2/" > etc/adios_config.tcl`
    `cat etc/adios_config.flags | sed -e 's/"//g' > etc/adios_config.mk`

  end # def

end
