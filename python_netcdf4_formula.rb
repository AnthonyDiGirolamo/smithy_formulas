class PythonNetcdf4Formula < Formula
  homepage "https://github.com/Unidata/netcdf4-python"
  url "https://github.com/Unidata/netcdf4-python/archive/v1.1.7rel.tar.gz"
  md5  "2e2d3ee7c2a26323f4d12a9d5c7b8d91"
  additional_software_roots [ config_value("lustre-software-root")[hostname] ]

  supported_build_names "python2.7.9"

  depends_on do
    python_module_from_build_name
  end

  module_commands do
    m = []
    if module_is_available?("PrgEnv-gnu")
      m << "unload PrgEnv-gnu PrgEnv-pgi PrgEnv-intel"
      m << "load PrgEnv-gnu"
      m << "load cray-hdf5"
      m << "load cray-netcdf"
    else
      m << "unload PE-gnu PE-pgi PE-intel"
      m << "load PE-gnu"
      m << "load hdf5"
      m << "load netcdf"
    end

    m << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/

    m << "unload python"
    m << "load #{python_module_from_build_name}"
    m << "load python_numpy"

    m
  end

  def install
    module_list

   # libdirs = []
   # case build_name
   # when /python3.3/
   #   libdirs << "#{prefix}/lib/python3.3/site-packages"
   # when /python2.7/
   #   libdirs << "#{prefix}/lib/python2.7/site-packages"
   # end
   # FileUtils.mkdir_p libdirs.first

    #python_start_command = "NETCDF4_DIR=$NETCDF_DIR PYTHONPATH=$PYTHONPATH:#{libdirs.join(":")} #{system_python} "

    system_python "setup.py build"
    system_python "setup.py install --prefix=#{prefix} --compile"
    #system "cd test && #{python_start_command} run_all.py"
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

    set LUSTREPREFIX #{additional_software_roots.first}/#{arch}/<%= @package.name %>/<%= @package.version %>/$BUILD

    prepend-path PYTHONPATH      $LUSTREPREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $LUSTREPREFIX/lib64/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages

  MODULEFILE
end
