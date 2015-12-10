class PythonSetuptoolsFormula < Formula
  homepage "https://pypi.python.org/"

  supported_build_names "python2.7", "python3"

  concern for_version("18.7.1") do
    included do
      url "https://pypi.python.org/packages/source/s/setuptools/setuptools-18.7.1.tar.gz"
      md5 "a0984da9cd8d7b582e1fd7de67dfdbcc"
    end
  end

  concern for_version("14.0") do
    included do
      url "https://pypi.python.org/packages/source/s/setuptools/setuptools-14.0.tar.gz"
      md5 "058655fe511deccb4359bf02727f5199"
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
