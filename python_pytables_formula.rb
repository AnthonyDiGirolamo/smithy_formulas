class PythonPytablesFormula < Formula
  homepage "http://www.pytables.org"
  url "http://downloads.sourceforge.net/project/pytables/pytables/3.0.0/tables-3.0.0.tar.gz"
  sha1 "0551bcb40cbb927efd74ba290a0ef4881dd18021"

  depends_on do
    packages = [ ]
    case build_name
    when /python3.3/
      packages << "python/3.3.2"
      packages << "python_numpy/*/*python3.3*"
      packages << "python_numexpr/*/*python3.3*"
      packages << "python_cython/*/*python3.3*"
    when /python2.7/
      packages << "python/2.7.5"
      packages << "python_numpy/*/*python2.7*"
      packages << "python_numexpr/*/*python2.7*"
      packages << "python_cython/*/*python2.7*"
    end
    packages
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
    commands << "load szip"
    commands << "load hdf5"
    commands << "swap hdf5 hdf5/#{$1}" if build_name =~ /hdf5([\d\.]+)/
    commands << "load python_numpy"
    commands << "load python_numexpr"
    commands << "load python_cython"
    commands
  end

  def install
    module_list

    hdf5_prefix = module_environment_variable("hdf5", "HDF5_DIR")

    ENV["CPPFLAGS"] = "-I#{hdf5_prefix}/include"
    ENV["LDFLAGS"]  = "-L#{hdf5_prefix}/lib"

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

    python_start_command = "PYTHONPATH=$PYTHONPATH:#{libdirs.join(":")} #{python_binary} "

    system "#{python_start_command} setup.py build"
    system "#{python_start_command} setup.py install --prefix=#{prefix} --compile"
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
    module load hdf5
    prereq hdf5
    module load python_numpy
    prereq python_numpy
    module load python_numexpr
    prereq python_numexpr

    if { [ is-loaded python/3.3.0 ] || [ is-loaded python/3.3.2 ] } {
      set BUILD python3.3
      set LIBDIR python3.3
    } elseif { [ is-loaded python/2.7.5 ] || [ is-loaded python/2.7.3 ] || [ is-loaded python/2.7.2 ] } {
      set BUILD python2.7
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
