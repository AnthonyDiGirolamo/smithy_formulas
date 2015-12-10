class PythonFireworksFormula < Formula
  homepage "https://pythonhosted.org/FireWorks/"
  url "https://github.com/materialsproject/fireworks/archive/v1.1.3.tar.gz"
  md5 "d22c11d44a2735481724a7469e180c0a"

  concern for_version(1.04) do
    included do
      url "https://github.com/materialsproject/fireworks/archive/v1.04.tar.gz"
      md5  "c34efc9ff2880bd23f5603e5aabed84b"
    end
  end

  supported_build_names /python2.7/, /python3/

  depends_on do
    python_module_from_build_name
  end

  modules do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    mods = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    mods << "unload python"

    mods << "load #{pe}gnu"
    mods << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/

    mods << "load #{python_module_from_build_name}"
    mods << "python_setuptools"
    mods
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
