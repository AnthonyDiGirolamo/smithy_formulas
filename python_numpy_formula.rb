class PythonNumpyFormula < Formula
  homepage "http://www.numpy.org/"
  url "http://downloads.sourceforge.net/project/numpy/NumPy/1.8.0/numpy-1.8.0.tar.gz"

  depends_on do
    packages = [ "cblas/20110120/*acml*" ]
    case build_name
    when /python3.3/
      packages << "python/3.3.2"
    when /python2.7/
      packages << "python/2.7.5"
    end
    packages
  end

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    case build_name
    when /gnu/
      commands << "load #{pe}gnu"
      commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
    when /pgi/
      commands << "load #{pe}pgi"
      commands << "swap pgi pgi/#{$1}" if build_name =~ /pgi([\d\.]+)/
    when /intel/
      commands << "load #{pe}intel"
      commands << "swap intel intel/#{$1}" if build_name =~ /intel([\d\.]+)/
    when /cray/
      commands << "load #{pe}cray"
      commands << "swap cce cce/#{$1}" if build_name =~ /cray([\d\.]+)/
    end

    commands << "load acml"
    commands << "unload python"

    case build_name
    when /python3.3/
      commands << "load python/3.3.2"
    when /python2.7/
      commands << "load python/2.7.5"
    end
    commands
  end

  def install
    module_list

    acml_prefix = module_environment_variable("acml/5.3.0", "ACML_DIR")
    acml_prefix += "/gfortran64"

    FileUtils.mkdir_p "#{prefix}/lib"
    FileUtils.cp "#{cblas.prefix}/lib/libcblas.a", "#{prefix}/lib", verbose: true
    FileUtils.cp "#{acml_prefix}/lib/libacml.a",   "#{prefix}/lib", verbose: true
    FileUtils.cp "#{acml_prefix}/lib/libacml.so",  "#{prefix}/lib", verbose: true

    ENV['CC']  = 'gcc'
    ENV['CXX'] = 'g++'
    ENV['OPT'] = '-O3 -funroll-all-loops'

    patch <<-EOF.strip_heredoc
      diff --git a/site.cfg b/site.cfg
      new file mode 100644
      index 0000000..c7a4c65
      --- /dev/null
      +++ b/site.cfg
      @@ -0,0 +1,15 @@
      +[blas]
      +blas_libs = cblas, acml
      +library_dirs = #{prefix}/lib
      +include_dirs = #{cblas.prefix}/include
      +
      +[lapack]
      +language = f77
      +lapack_libs = acml
      +library_dirs = #{acml_prefix}/lib
      +include_dirs = #{acml_prefix}/include
      +
      +[fftw]
      +libraries = fftw3
      +library_dirs = /opt/fftw/3.3.0.1/x86_64/lib
      +include_dirs = /opt/fftw/3.3.0.1/x86_64/include
    EOF

    system "cat site.cfg"

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
      set BUILD python3.3_acml5.3.0_gnu4.7.1
      set LIBDIR python3.3
    } elseif { [ is-loaded python/2.7.5 ] || [ is-loaded python/2.7.3 ] || [ is-loaded python/2.7.2 ] } {
      set BUILD python2.7_acml5.3.0_gnu4.7.1
      set LIBDIR python2.7
    }
    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib64
    prepend-path LD_LIBRARY_PATH /opt/gcc/4.7.2/snos/lib64
    prepend-path LD_LIBRARY_PATH /ccs/compilers/gcc/rhel6-x86_64/4.7.1/lib
    prepend-path LD_LIBRARY_PATH /ccs/compilers/gcc/rhel6-x86_64/4.7.1/lib64
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
