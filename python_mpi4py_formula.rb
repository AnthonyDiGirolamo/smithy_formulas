class PythonMpi4pyFormula < Formula
  homepage "https://bitbucket.org/mpi4py/mpi4py/overview"
  url "https://bitbucket.org/mpi4py/mpi4py/downloads/mpi4py-2.0.0.tar.gz"

  additional_software_roots [ config_value("lustre-software-root")[hostname] ]

  supported_build_names "python2.7", "python3"

  depends_on do
    [ python_module_from_build_name ]
  end

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if cray_system?

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    commands << "load #{pe}gnu"
    commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
    commands << "unload python"
    commands << "load cray-mpich" if cray_system?
    commands << "load #{python_module_from_build_name}"
    commands
  end

  def install
    module_list

    cray_build = true if module_is_available?("PrgEnv-gnu")

    if cray_build
      File.open("mpi.cfg", "w+") do |f|
        f.write <<-EOF.strip_heredoc
          [cray]
          mpi_dir = #{module_environment_variable("cray-mpich", "MPICH_DIR")}
          mpicc   = cc
          mpicxx  = CC
        EOF
      end

      ENV["PE_LINK_TYPE"] = "dynamic"
      ENV["CRAYPE_LINK_TYPE"] = "dynamic"

      system "cat mpi.cfg"
    end

    build_options = ""
    build_options = "--mpicc=cc --mpi=cray" if cray_build

    if build_name =~ /python3.*/
      system "python3 setup.py build #{build_options}"
      system "python3 setup.py install --prefix=#{prefix} --compile"
    else
      system_python "setup.py build #{build_options}"
      system_python "setup.py install --prefix=#{prefix} --compile"
    end
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
  MODULEFILE
end
