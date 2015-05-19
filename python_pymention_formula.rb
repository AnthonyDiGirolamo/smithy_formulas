class PythonPymentionFormula < Formula
  homepage "https://github.com/davidbgk/pymention"
  url "https://github.com/davidbgk/pymention/archive/master.zip"

  supported_build_names "python2.7.9"

  depends_on do
    python_module_from_build_name
  end

  module_commands do
    m = []
    if module_is_available?("PrgEnv-gnu")
      m << "unload PrgEnv-gnu PrgEnv-pgi PrgEnv-intel"
      m << "load PrgEnv-gnu"
    else
      m << "unload PE-gnu PE-pgi PE-intel"
      m << "load PE-gnu"
    end
    m << "unload python"
    m << "load #{python_module_from_build_name}"
    m << "load python_setuptools"
    m
  end

  def install
    module_list
    
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
    prereq python_webtest
    prereq python_gunicorn
    prereq python_requests

    <%= python_module_build_list @package, @builds %>
    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib64
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
