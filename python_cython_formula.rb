class PythonCythonFormula < Formula
  homepage "http://cython.org/"
  additional_software_roots [ config_value("lustre-software-root")[hostname] ]

  supported_build_names "python2.7", "python3"

  concern for_version("0.22") do
    included do
      url "https://pypi.python.org/packages/source/C/Cython/cython-0.22.tar.gz"
      md5 "1ae25add4ef7b63ee9b4af697300d6b6"
    end
  end

  depends_on do
    python_module_from_build_name
  end

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if cray_system?

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    commands << "load #{pe}gnu"
    commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
    commands << "unload python"
    commands << "load #{python_module_from_build_name}"
    commands
  end

  def install
    module_list
    system_python "setup.py build"
    system_python "setup.py install --prefix=#{prefix} --compile"
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
    prereq PrgEnv-gnu PE-gnu

    <%= python_module_build_list @package, @builds %>
    set PREFIX <%= @package.version_directory %>/$BUILD

    set LUSTREPREFIX #{additional_software_roots.first}/#{arch}/<%= @package.name %>/<%= @package.version %>/$BUILD

    prepend-path PYTHONPATH      $LUSTREPREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $LUSTREPREFIX/lib64/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
