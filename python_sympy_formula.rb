class PythonSympyFormula < Formula
  homepage "http://yt-project.org/doc/index.html"

  concern for_version("0.7.5") do
    included do
      url "https://github.com/sympy/sympy/releases/download/sympy-0.7.5/sympy-0.7.5.tar.gz"
      md5 "7de1adb49972a15a3dd975e879a2bea9"
    end
  end

  concern for_version("0.7.6") do
    included do
      url "https://github.com/sympy/sympy/releases/download/sympy-0.7.6/sympy-0.7.6.tar.gz"
      md5 "3d04753974306d8a13830008e17babca"
    end
  end

  supported_build_names "python2.7", "python3"
  
  depends_on do
    python_module_from_build_name
  end

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    commands << "load #{pe}gnu"
    commands << "swap gcc gcc/#{1}" if build_name =~ /gnu([\d\.]+)/
    commands << "unload python"
    commands << "load #{python_module_from_build_name}"
    
    commands
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
    module load python_numpy ipython python_h5py hdf5
    prereq python_numpy

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
