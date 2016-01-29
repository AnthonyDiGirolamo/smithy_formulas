class PythonScipyFormula < Formula
  homepage "http://www.scipy.org"

  additional_software_roots [ config_value("lustre-software-root")[hostname] ]

  supported_build_names "python2.7", "python3"

  depends_on do
    dependencies = [ python_module_from_build_name ]
    dependencies << "python_numpy/1.9.2/*#{python_version_from_build_name}*"
    dependencies << "cblas/20110120/*libsci*" if build_name.include? "libsci"
    dependencies
  end

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if cray_system?

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    commands << "load #{pe}gnu"
    commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/

    commands << "load cray-libsci" if build_name.include? "libsci"

    commands << "unload python"
    commands << "load #{python_module_from_build_name}"
    commands << "load python_numpy/1.9.2"
    commands << "load python_nose" # needed to run test suite
    commands
  end

  concern for_version("0.17.0") do
    included do
      url "https://github.com/scipy/scipy/releases/download/v0.17.0/scipy-0.17.0.tar.gz"
    end
  end

  concern for_version("0.15.1") do
    included do
      url "http://downloads.sourceforge.net/project/scipy/scipy/0.15.1/scipy-0.15.1.tar.gz"
    end
  end

  concern for_version("0.13.0") do
    included do
      depends_on do
        [ python_module_from_build_name, "python_numpy/1.8.0/#{python_version_from_build_name}*" ]
      end

      module_commands do
        [ "unload python", "load #{python_module_from_build_name}", "load python_numpy/1.8.0" ]
      end
    end
  end

  def install
    module_list

    ENV['CC']  = 'gcc'
    ENV['CXX'] = 'g++'
    ENV['OPT'] = '-O3 -funroll-all-loops'

    if build_name.include? "libsci"
      ENV['CC']  = 'cc'
      ENV['CXX'] = 'CC'
      snos_libs = module_environment_variable("gcc", "LD_LIBRARY_PATH")
      FileUtils.cp "#{snos_libs}/libstdc++.so.6", "#{prefix}/lib", verbose: true
    end

    system_python "setup.py build"
    system_python "setup.py install --prefix=#{prefix} --compile"
  end

  def test
    module_list
    Dir.chdir prefix
    system "PYTHONPATH=$PYTHONPATH:#{prefix}/lib/#{python_libdir(current_python_version)}/site-packages",
      "LD_LIBRARY_PATH=#{prefix}/lib:$LD_LIBRARY_PATH",
      "python -c 'import nose, scipy; scipy.test()'"

    notice_warn <<-EOF.strip_heredoc
      Testing scipy:
      module load python python_nose python_numpy python_scipy
      python -c 'import nose, numpy, scipy; scipy.test()'
    EOF
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    prereq PrgEnv-gnu PE-gnu
    prereq python
    conflict python_scipy
    prereq python_numpy

    <%= python_module_build_list @package, @builds %>
    set PREFIX <%= @package.version_directory %>/$BUILD

    set LUSTREPREFIX #{additional_software_roots.first}/#{arch}/<%= @package.name %>/<%= @package.version %>/$BUILD

    prepend-path PYTHONPATH      $LUSTREPREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $LUSTREPREFIX/lib64/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end

