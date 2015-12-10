class PythonNetcdf4Formula < Formula
  homepage "http://code.google.com/p/netcdf4-python/"
  url "http://netcdf4-python.googlecode.com/files/netCDF4-1.0.6.tar.gz"
  sha1 "c409355f491e43d7ff8a49775d0a248a0186205d"

  supported_build_names "python2.7", "python3"

  depends_on do
    python_module_from_build_name
  end
  
  params hdf5_module_name:   module_is_available?("cray-hdf5") ? "cray-hdf5" : "hdf5",
         netcdf_module_name: module_is_available?("cray-netcdf") ? "cray-netcdf" : "netcdf"

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]

    commands << "load #{pe}gnu"
    commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/

    commands << "unload python"

    commands << "load #{python_module_from_build_name}"

    commands << "load python_numpy"

    @hdf5_module_name = "#{$1}hdf5/#{$2}" if build_name =~ /(cray-)?hdf5([\d\.]+)/
    commands << "load " + hdf5_module_name

    @netcdf_module_name = "#{$1}netcdf/#{$2}" if build_name =~ /(cray-)?netcdf([\d\.]+)/
    commands << "load " + netcdf_module_name

    commands
  end

  def install
    module_list

    ENV["NETCDF4_DIR"] = module_environment_variable(netcdf_module_name, "NETCDF_DIR")
    system_python "setup.py build"
    system_python "setup.py install --prefix=#{prefix} --compile"
#    system_python "cd test && #{python_start_command} run_all.py"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    prereq python
    module load python_numpy
    prereq python_numpy

    <%= python_module_build_list @package, @builds %>

    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PATH            $PREFIX/bin
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages

    prepend-path PATH            /opt$PREFIX/bin
    prepend-path PYTHONPATH      /opt$PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      /opt$PREFIX/lib64/$LIBDIR/site-packages

    prepend-path LD_LIBRARY_PATH /opt/cray/lib64
  MODULEFILE
end
