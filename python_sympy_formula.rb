class PythonSympyFormula < Formula
  homepage "http://yt-project.org/doc/index.html"
  url "https://github.com/sympy/sympy/releases/download/sympy-0.7.5/sympy-0.7.5.tar.gz"
  md5 "7de1adb49972a15a3dd975e879a2bea9"

  version "0.7.5"

  depends_on do
    case build_name
    when /python3.3/
      [ "python/3.3.2"]
    when /python2.7/
      [ "python/2.7.5" ]
    end
  end

  modules do
    case build_name
    when /python3.3/
      [ "python/3.3.2", "gcc" ]
    when /python2.7/
      [ "python/2.7.5", "gcc" ]
    end
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

    system "PYTHONPATH=$PYTHONPATH:#{libdirs.join(":")} #{python_binary} setup.py install --prefix=#{prefix} --compile"
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
    module load python_numpy ipython python_h5py hdf5
    prereq python_numpy

    if { [ is-loaded python/3.3.0 ] || [ is-loaded python/3.3.2 ] } {
      set BUILD python3.3
      set LIBDIR python3.3
    } elseif { [ is-loaded python/2.7.5 ] || [ is-loaded python/2.7.3 ] || [ is-loaded python/2.7.2 ] } {
      set BUILD python2.7
      set LIBDIR python2.7
    }
    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib64
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
