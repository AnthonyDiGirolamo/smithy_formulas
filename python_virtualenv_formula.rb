class PythonVirtualenvFormula < Formula
  homepage "https://virtualenv.pypa.io/"
  url "https://pypi.python.org/packages/source/v/virtualenv/virtualenv-13.0.1.tar.gz"
  md5 "1ffc011bde6667f0e37ecd976f4934db"

  supported_build_names /python2.6/, /python2.7/, /python3/

  depends_on do
    python_module_from_build_name
  end

  module_commands do
    [ "unload python",
      "load #{python_module_from_build_name}",
      "load python_setuptools"]
  end

  def install
    module_list

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
    prereq python_setuptools
    prereq python_pip

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
