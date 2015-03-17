class PythonMpi4pyFormula < Formula
  homepage "https://bitbucket.org/mpi4py/mpi4py/overview"
  url "https://bitbucket.org/mpi4py/mpi4py/downloads/mpi4py-1.3.1.tar.gz"
  sha1 "083a4a9b6793dfdbd852082d8b95da08bcf57290"

  supported_build_names "python2.7", "python3"

  depends_on do
    build_name_python
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
    m << "load #{build_name_python}"
    m
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
    build_options = "--mpi=cray" if cray_build

    system_python "setup.py build #{build_options}"
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

    set LUSTREPREFIX /lustre/atlas/sw/xk7/<%= @package.name %>/<%= @package.version %>/$BUILD

    prepend-path PYTHONPATH      $LUSTREPREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $LUSTREPREFIX/lib64/$LIBDIR/site-packages

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib64
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
