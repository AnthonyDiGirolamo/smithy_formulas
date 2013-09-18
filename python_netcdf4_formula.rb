class PythonNetcdf4Formula < Formula
  homepage "http://code.google.com/p/netcdf4-python/"
  url "http://netcdf4-python.googlecode.com/files/netCDF4-1.0.5.tar.gz"
  sha1 "acd98355cca11b7302f7a3f1181d07c504ad7916"

  depends_on do
    packages = [ ]
    case build_name
    when /python3.3/
      packages << "python/3.3.0"
      packages << "python_numpy/*/*python3.3.0*"
    when /python2.7/
      packages << "python/2.7.3"
      packages << "python_numpy/*/*python2.7.3*"
    when /python2.6/
      packages << "python_numpy/*/*python2.6.8*"
      packages << "python_ordereddict/*/*python2.6.8*"
    end

    packages
  end

  module_commands do
    m = [ "unload PrgEnv-gnu PrgEnv-pgi PrgEnv-cray PrgEnv-intel" ]
    m << "load PrgEnv-gnu"

    m << "unload python"
    case build_name
    when /python3.3/
      m << "load python/3.3.0"
    when /python2.7/
      m << "load python/2.7.3"
    when /python2.6/
      m << "load python_ordereddict"
    end

    m << "load python_numpy"

    if build_name =~ /netcdf([\d\.]+)/
      m << "load netcdf/#{$1}"
    else
      m << "load netcdf/4.2.0"
    end

    if build_name =~ /hdf5([\d\.]+)/
      m << "load hdf5/#{$1}"
    else
      m << "load hdf5/1.8.8"
    end
    m
  end

  def install
    module_list

    python_binary = "python"
    libdirs = []
    case build_name
    when /python3.3/
      python_binary = "python3.3"
      libdirs << "#{prefix}/lib/python3.3/site-packages"
    when /python2.7/
      libdirs << "#{prefix}/lib/python2.7/site-packages"
    when /python2.6/
      libdirs << "#{prefix}/lib64/python2.6/site-packages"
    end
    FileUtils.mkdir_p libdirs.first

    python_start_command = "NETCDF4_DIR=$NETCDF_DIR PYTHONPATH=$PYTHONPATH:#{libdirs.join(":")} #{python_binary} "

    system "#{python_start_command} setup.py build"
    system "#{python_start_command} setup.py install --prefix=#{prefix} --compile"
    system "cd test && #{python_start_command} run_all.py"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    module load python_numpy
    prereq python_numpy

    if [ is-loaded python/3.3.0 ] {
      set BUILD python3.3.0_netcdf4.2.0
      set LIBDIR python3.3
    } elseif { [ is-loaded python/2.7.3 ] || [ is-loaded python/2.7.2 ] } {
      set BUILD python2.7.3_netcdf4.2.0
      set LIBDIR python2.7
    } else {
      module load python_ordereddict
      prereq python_ordereddict
      set BUILD python2.6.8_netcdf4.2.0
      set LIBDIR python2.6
    }
    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PATH            $PREFIX/bin
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages

    prepend-path PATH            /opt$PREFIX/bin
    prepend-path PYTHONPATH      /opt$PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      /opt$PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
