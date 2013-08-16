class PythonPytablesFormula < Formula
  homepage "http://www.pytables.org"
  url "http://downloads.sourceforge.net/project/pytables/pytables/3.0.0/tables-3.0.0.tar.gz"
  sha1 "0551bcb40cbb927efd74ba290a0ef4881dd18021"

  depends_on do
    packages = [ ]
    case build_name
    when /python3.3/
      packages << "python/3.3.0"
      packages << "python_numpy/*/*python3.3.0*"
      packages << "python_numexpr/*/*python3.3.0*"
      packages << "python_cython/*/*python3.3.0*"
    when /python2.7/
      packages << "python/2.7.3"
      packages << "python_numpy/*/*python2.7.3*"
      packages << "python_numexpr/*/*python2.7.3*"
      packages << "python_cython/*/*python2.7.3*"
    when /python2.6/
      packages << "python_numpy/*/*python2.6.8*"
      packages << "python_numexpr/*/*python2.6.8*"
      packages << "python_cython/*/*python2.6.8*"
    end
    packages
  end

  module_commands do
    m = [ "unload PrgEnv-gnu PrgEnv-pgi PrgEnv-cray PrgEnv-intel" ]
    case build_name
    when /gnu/
      m << "load PrgEnv-gnu"
    when /pgi/
      m << "load PrgEnv-pgi"
    when /intel/
      m << "load PrgEnv-intel"
    when /cray/
      m << "load PrgEnv-cray"
    end

    m << "unload python"
    case build_name
    when /python3.3/
      m << "load python/3.3.0"
    when /python2.7/
      m << "load python/2.7.3"
    end

    m << "load python_numpy"
    m << "load python_numexpr"
    m << "load python_cython"
    m << "load hdf5/1.8.8"
    m
  end

  def install
    module_list

    hdf5_prefix = `#{@modulecmd} display hdf5/1.8.8 2>&1|grep HDF5_DIR`.split[2]

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
    when /python2.6/
      libdirs << "#{prefix}/lib64/python2.6/site-packages"
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

    module load python_numpy
    prereq python_numpy
    module load python_numexpr
    prereq python_numexpr

    if [ is-loaded python/3.3.0 ] {
      set BUILD python3.3.0
      set LIBDIR python3.3
    } elseif { [ is-loaded python/2.7.3 ] || [ is-loaded python/2.7.2 ] } {
      set BUILD python2.7.3
      set LIBDIR python2.7
    } else {
      set BUILD python2.6.8
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
