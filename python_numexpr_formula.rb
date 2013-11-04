class PythonNumexprFormula < Formula
  homepage "http://code.google.com/p/numexpr/"
  url "http://numexpr.googlecode.com/files/numexpr-2.2.2.tar.gz"
  sha1 "021cbd31e6976164b4b956318b30630dabd16159"

  depends_on do
    case build_name
    when /python3.3/
      [ "python/3.3.2", "python_numpy/1.8.0/*python3.3*" ]
    when /python2.7/
      [ "python/2.7.5", "python_numpy/1.8.0/*python2.7*" ]
    end
  end

  modules do
    case build_name
    when /python3.3/
      [ "python/3.3.2", "python_numpy/1.8.0", "gcc" ]
    when /python2.7/
      [ "python/2.7.5", "python_numpy/1.8.0", "gcc" ]
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

    if { [ is-loaded python/3.3.0 ] || [ is-loaded python/3.3.2 ] } {
      set BUILD python3.3
      set LIBDIR python3.3
    } elseif { [ is-loaded python/2.7.5 ] || [ is-loaded python/2.7.3 ] || [ is-loaded python/2.7.2 ] } {
      set BUILD python2.7
      set LIBDIR python2.7
    }
    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages

    prepend-path PYTHONPATH      /opt$PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      /opt$PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
