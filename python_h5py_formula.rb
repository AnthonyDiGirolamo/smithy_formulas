class PythonH5pyFormula < Formula
  homepage "http://www.h5py.org/"

  supported_build_names /python.*_hdf5.*/


  additional_software_roots [ config_value("lustre-software-root")[hostname] ]
  #additional_software_roots [ config_value("lustre-software-root").fetch(hostname) ] if cray_system?

  concern for_version("2.5.0") do
    included do
      url "https://pypi.python.org/packages/source/h/h5py/h5py-2.5.0.tar.gz"
      md5 "6e4301b5ad5da0d51b0a1e5ac19e3b74"
    end
  end

  concern for_version("2.6.0_parallel") do    #Same package as for_version(2.6.0), but allows to turn on hdf5-parallel support with version number
    included do
      url "https://pypi.python.org/packages/source/h/h5py/h5py-2.6.0.tar.gz"
      md5 "ec476211bd1de3f5ac150544189b0bf4"
    end
  end

  concern for_version("2.6.0") do
    included do
      url "https://pypi.python.org/packages/source/h/h5py/h5py-2.6.0.tar.gz"
      md5 "ec476211bd1de3f5ac150544189b0bf4"
    end
  end

  concern for_version("2.4.0") do
    included do
      url "https://pypi.python.org/packages/source/h/h5py/h5py-2.4.0.tar.gz"
      md5 "80c9a94ae31f84885cc2ebe1323d6758"
    end
  end

  concern for_version("2.2.0") do
    included do
      url "http://h5py.googlecode.com/files/h5py-2.2.0.tar.gz"
      sha1 "65e5d6cc83d9c1cb562265a77a46def22e9e6593"
    end
  end

  depends_on do
    [ python_module_from_build_name,
      "python_numpy/*/#{python_version_from_build_name}*" ]
  end

  module_commands do
    hdf5_module_name = ""
    case cray_system? 
    when true
      if version =~ /([\d\.]+)_parallel/
        hdf5_module_name = "cray-hdf5-parallel"
      else
        hdf5_module_name = "cray-hdf5"
      end
    when false
      hdf5_module_name = "hdf5"
    end
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]

    commands << "load #{pe}gnu"
    commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/

    commands << "unload python"
    commands << "load #{python_module_from_build_name}"
    commands << "load python_mpi4py"
    commands << "load python_numpy/1.9.2"
    #commands << "swap python_numpy python_numpy/#{$1}" if build_name =~ /numpy([\d\.]+)/
    commands << "load python_cython"
    commands << "load python_nose"
    commands << "load szip"
    commands << "load python_setuptools"

    commands << "load #{hdf5_module_name}"
    commands << "swap #{hdf5_module_name} #{hdf5_module_name}/#{$1}" if build_name =~ /hdf5([\d\.]+)/
    commands
  end

  hdf5_module_name = ""
  
  def install
    case cray_system? 
    when true
      if version =~ /([\d\.]+)_parallel/
        hdf5_module_name = "cray-hdf5-parallel"
      else
        hdf5_module_name = "cray-hdf5"
      end
    when false
      hdf5_module_name = "hdf5"
    end
    module_list

    hdf5_prefix = module_environment_variable(hdf5_module_name, "HDF5_DIR")
    mpich_prefix = module_environment_variable("cray-mpich", "CRAY_MPICH2_DIR")

    ENV["CPPFLAGS"] = "-I#{hdf5_prefix}/include -I#{mpich_prefix}/include"
    ENV["LDFLAGS"]  = "-L#{hdf5_prefix}/lib -L#{mpich_prefix}/lib"
    

    system_python "setup.py configure --mpi --hdf5=#{hdf5_prefix}" if version =~ /([\d\.]+)_parallel/
    system_python "setup.py install --prefix=#{prefix}"
    #system_python "setup.py build"
    #system_python "setup.py test"
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
    module load #{hdf5_module_name}
    prereq #{hdf5_module_name}
    module load python_numpy/1.9.2
    prereq python_numpy/1.9.2

    <%= python_module_build_list @package, @builds %>
    set PREFIX <%= @package.version_directory %>/$BUILD
    set LUSTREPREFIX #{additional_software_roots.first}/#{arch}/<%= @package.name %>/<%= @package.version %>/$BUILD

    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $LUSTREPREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $LUSTREPREFIX/lib64/$LIBDIR/site-packages

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib64
    prepend-path LD_LIBRARY_PATH $LUSTREPREFIX/lib
    prepend-path LD_LIBRARY_PATH $LUSTREPREFIX/lib64
    prepend-path MANPATH         $PREFIX/share/man
    MODULEFILE
end
