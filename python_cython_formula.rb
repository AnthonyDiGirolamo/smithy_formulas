class PythonCythonFormula < Formula
  homepage "http://cython.org/"

  supported_build_names /python2.7/, /python3/

  concern for_version("0.22") do
    included do
      url "https://pypi.python.org/packages/source/C/Cython/cython-0.22.tar.gz"
      md5 "1ae25add4ef7b63ee9b4af697300d6b6"
    end
  end

  concern for_version("0.19.1") do
    included do
      url "http://cython.org/release/Cython-0.19.1.tar.gz"
    end
  end

  depends_on do
    python_module_from_build_name
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

    prepend-path PATH            $PREFIX/bin
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
    prepend-path MANPATH         $PREFIX/share/man
  MODULEFILE
end
