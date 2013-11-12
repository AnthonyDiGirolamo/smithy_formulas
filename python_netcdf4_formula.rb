class PythonNetcdf4Formula < Formula
  homepage "http://code.google.com/p/netcdf4-python/"
  url "http://netcdf4-python.googlecode.com/files/netCDF4-1.0.6.tar.gz"
  sha1 "c409355f491e43d7ff8a49775d0a248a0186205d"

  depends_on do
    case build_name
    when /python3.3/
      ["python/3.3.2", "python_numpy/*/*python3.3*"]
    when /python2.7/
      ["python/2.7.5", "python_numpy/*/*python2.7*"]
    end
  end

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]

    commands << "load #{pe}gnu"
    commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/

    commands << "unload python"
    case build_name
    when /python3.3/
      commands << "load python/3.3.2"
    when /python2.7/
      commands << "load python/2.7.5"
    end

    commands << "load python_numpy"

    commands << "load hdf5"
    commands << "swap hdf5 hdf5/#{$1}" if build_name =~ /hdf5([\d\.]+)/

    commands << "load netcdf"
    commands << "swap netcdf netcdf/#{$1}" if build_name =~ /netcdf([\d\.]+)/

    commands
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

    prereq python
    module load python_numpy
    prereq python_numpy

    if { [ is-loaded python/3.3.0 ] || [ is-loaded python/3.3.2 ] } {
      set BUILD python3.3_netcdf4.1.3
      set LIBDIR python3.3
    } elseif { [ is-loaded python/2.7.5 ] || [ is-loaded python/2.7.3 ] || [ is-loaded python/2.7.2 ] } {
      set BUILD python2.7_netcdf4.1.3
      set LIBDIR python2.7
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
