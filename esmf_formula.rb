class EsmfFormula < Formula
  homepage "http://www.earthsystemmodeling.org/"
  url "http://www.earthsystemmodeling.org/esmf_releases/non_public/ESMF_6_2_0/esmf_6_2_0_src.tar.gz"
  version "6.2.0"

  module_commands do
    commands = [ "unload PrgEnv-gnu PrgEnv-intel PrgEnv-pathscale PrgEnv-pgi pgi netcdf hdf5" ]
    case build_name
    when /pgi/
      commands << "load PrgEnv-pgi"
      if build_name =~ /pgi([\d\.]+)/
        commands << "swap pgi pgi/#{$1}"
      end
    when /gnu/
      commands << "load PrgEnv-gnu"
      if build_name =~ /gnu([\d\.]+)/
        commands << "swap gcc gcc/#{$1}"
      end
    when /intel/
      commands << "load PrgEnv-intel"
      if build_name =~ /intel([\d\.]+)/
        commands << "swap intel intel/#{$1}"
      end
    end
    #commands << "swap xtpe-interlagos xtpe-istanbul"
    # netcdf/4.2.0 c++ api not compatible!
    commands << "load szip cray-netcdf" if build_name.include?("netcdf")
    commands
  end

  def install
    module_list

    ENV["ESMF_BOPT"] = "O"
    ENV["ESMF_OS"]   = "Unicos"
    ENV["ESMF_DIR"]  = "#{prefix}/source"
    ENV["ESMF_COMM"] = "mpi"

    ENV["ESMF_INSTALL_BINDIR"]    = "#{prefix}/bin"
    ENV["ESMF_INSTALL_LIBDIR"]    = "#{prefix}/lib"
    ENV["ESMF_INSTALL_HEADERDIR"] = "#{prefix}/include"

    ENV["ESMF_COMPILER"] = "default"
    ENV["ESMF_COMPILER"] = "gnu"   if build_name.include?("gnu")
    ENV["ESMF_COMPILER"] = "pgi"   if build_name.include?("pgi")
    ENV["ESMF_COMPILER"] = "intel" if build_name.include?("intel")

    ENV["ESMF_MPIRUN"] = "mpirun.unicos.batch"
    ENV["ESMF_MPIBATCHOPTIONS"] = "-A STF007 -q debug"
    ENV["ESMF_INSTALL_HEADERDIR"] = "#{prefix}/include"
    ENV["ESMF_INSTALL_LIBDIR"] = "#{prefix}/lib"
    ENV["ESMF_INSTALL_MODDIR"] = "#{prefix}/include"

    ENV["ESMF_LAPACK"] = "netlib" if build_name.include?("lapack")

    if build_name.include?("netcdf")
      netcdf_prefix = module_environment_variable("netcdf/4.1.3", "NETCDF_DIR")
      hdf5_prefix   = module_environment_variable("hdf5/1.8.7", "HDF5_DIR")

      ENV["ESMF_NETCDF"] = "split"
      ENV["ESMF_NETCDF_INCLUDE"] = "#{netcdf_prefix}/include"
      ENV["ESMF_NETCDF_LIBPATH"] = "#{netcdf_prefix}/lib -L#{hdf5_prefix}/lib"
      ENV["ESMF_NETCDF_LIBS"] = "'-lnetcdf_c++ -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lm -lz'"
    end

    system "make info"
    system "make -j 8 all ; make install"
    # system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    <% if @builds.size > 1 %>
    <%= module_build_list @package, @builds %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    <% else %>
    set PREFIX <%= @package.prefix %>
    <% end %>

    setenv ESMF_BINDIR $PREFIX/bin
    setenv ESMF_LIBDIR $PREFIX/lib
    setenv ESMFMKFILE  $PREFIX/lib/esmf.mk
  MODULEFILE
end
