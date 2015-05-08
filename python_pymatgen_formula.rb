class PythonPymatgenFormula < Formula
  homepage "http://pymatgen.org"
  url "https://github.com/materialsproject/pymatgen/archive/v3.0.13.tar.gz"
  additional_software_roots [ config_value("lustre-software-root")[Smithy::Config.hostname] ]

  supported_build_names "python2.7.9"

  depends_on do
    python_module_from_build_name
  end

  module_commands do
    m = []
    if module_is_available?("PrgEnv-gnu")
      m << "unload PrgEnv-cray PrgEnv-gnu PrgEnv-pgi PrgEnv-intel"
      m << "load PrgEnv-gnu"
    else
      m << "unload PE-gnu PE-pgi PE-intel"
      m << "load PE-gnu"
    end
    m << "unload python"
    m << "load #{python_module_from_build_name}"
    m << "load python_setuptools"
    m << "load python_numpy"
    m << "load python_scipy"
    m
  end

  def install
    module_list

    ENV["CRAYPE_LINK_TYPE"] = "dynamic" 
    ENV['CC']  = 'cc'
    ENV['CXX'] = 'CC'

    system_python "setup.py develop --prefix=#{prefix}"
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

    set LUSTREPREFIX /lustre/atlas/sw/xk7/<%= @package.name %>/<%= @package.version %>/$BUILD

    prepend-path PYTHONPATH      $LUSTREPREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $LUSTREPREFIX/lib64/$LIBDIR/site-packages

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib64
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
