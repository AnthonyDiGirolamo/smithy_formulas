class PythonScipyFormula < Formula
  # Testing yaml:
  # module load python 
  # python setup.py test

  homepage "https://pypi.python.org/pypi/PyYAM"
  url "http://pyyaml.org/download/pyyaml/PyYAML-3.11.tar.gz"
  additional_software_roots [ config_value("lustre-software-root")[hostname] ]

  supported_build_names "python2.7", "python3"

  depends_on do
     [python_module_from_build_name,"python_setuptools/*/*#{python_version_from_build_name}*"]  
  end

  module_commands do
    ["unload python", "load #{python_module_from_build_name}"]
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

    <%= python_module_build_list @package, @builds %>
    set PREFIX <%= @package.version_directory %>/$BUILD

    set LUSTREPREFIX #{additional_software_roots.first}/#{arch}/<%= @package.name %>/<%= @package.version %>/$BUILD

    prepend-path PYTHONPATH      $LUSTREPREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $LUSTREPREFIX/lib64/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end

