class PythonPipFormula < Formula
  homepage "https://pypi.python.org/pypi/pip"

  supported_build_names "python2.7", "python3"

  concern for_version("1.5.1") do
    included do
      url "https://pypi.python.org/packages/source/p/pip/pip-1.5.1.tar.gz"
    end
  end

  concern for_version("6.0.8") do
    included do
      url "https://pypi.python.org/packages/source/p/pip/pip-6.0.8.tar.gz"
      md5 "2332e6f97e75ded3bddde0ced01dbda3"
    end
  end

  concern for_version("7.1.2") do
    included do
      url "https://pypi.python.org/packages/source/p/pip/pip-7.1.2.tar.gz"
      md5 "3823d2343d9f3aaab21cf9c917710196"
    end
  end

  depends_on do
    [ python_module_from_build_name,
      "python_setuptools/*/*#{python_version_from_build_name}" ]
  end

  module_commands do
    ["unload python",
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
