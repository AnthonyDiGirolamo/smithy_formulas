class PythonScipyFormula < Formula
  homepage "http://www.scipy.org"
  url "http://downloads.sourceforge.net/project/scipy/scipy/0.15.1/scipy-0.15.1.tar.gz"
  additional_software_roots [ config_value("lustre-software-root")[hostname] ]

  supported_build_names "python2.7", "python3"

  depends_on do
    [ python_module_from_build_name, "python_numpy/1.9.2/*#{python_version_from_build_name}*" ]
  end

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    commands << "load #{pe}gnu"
    commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
    [ "unload python", "load #{python_module_from_build_name}", "load python_numpy/1.9.2" ]
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

