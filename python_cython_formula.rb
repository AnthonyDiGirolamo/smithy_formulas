class PythonCythonFormula < Formula
  homepage "http://cython.org/"
  url "http://cython.org/release/Cython-0.19.2.tar.gz"
  md5 "4af1218346510b464c0a6bf15500d0e2"

  depends_on do
    packages = [ ]
    case build_name
    when /python3.3/
      packages << "python/3.3.2"
    when /python2.7/
      packages << "python/2.7.3"
    end
    packages
  end

  module_commands do
    commands = ["purge"]
    commands << "unload python"
    case build_name
    when /python3.3/
      commands << "load python/3.3.2"
    when /python2.7/
      commands << "load python/2.7.3"
    end
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

    if { [ is-loaded python/3.3.0 ] || [ is-loaded python/3.3.2 ] } {
      set BUILD python3.3
      set LIBDIR python3.3
    } elseif { [ is-loaded python/2.7.3 ] || [ is-loaded python/2.7.3 ] || [ is-loaded python/2.7.2 ] } {
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
