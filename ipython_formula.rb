class IpythonFormula < Formula
  homepage "http://ipython.org/"

  concern for_version("1.1.0") do
    included do
      url "https://github.com/ipython/ipython/releases/download/rel-1.1.0/ipython-1.1.0.tar.gz"
    end
  end

  concern for_version("3.0.0") do
    included do
      url "https://pypi.python.org/packages/source/i/ipython/ipython-3.0.0.tar.gz"
      md5 "b3f00f3c0be036fafef3b0b9d663f27e"
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
    module load python_setuptools
    prereq python_setuptools

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
