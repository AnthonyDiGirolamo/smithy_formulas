class ParaviewCrayFormula < Formula
  homepage "http://www.paraview.org"
#  url "http://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v4.1&type=source&os=all&downloadFile=ParaView-v4.1.0-source.tar.gz"
  url "none"
  version "dev"

  module_commands [
    "unload PrgEnv-pgi PrgEnv-cray PrgEnv-intel PrgEnv-gnu",
    "load PrgEnv-gnu",
    "load git",
    "load cmake",
    "load python",
    "load python_mpi4py",
#    "switch craype-interlagos craype-istanbul",
  ]

  def install
    env_vars = [
      "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cray/xe-sysroot/4.1.40/usr/lib/alps",
#      "export XTPE_LINK_TYPE=dynamic",
#      "export CRAYPE_LINK_TYPE=dynamic",
    ].join(" ; ") + " ; "

    module_list

    FileUtils.mkdir_p prefix+"/build"

    system "git clone git://paraview.org/ParaView.git source" unless Dir.exists?("source")
    Dir.chdir prefix+"/source"
    system "git checkout -b trunk origin/release"
    system "git checkout tags/v4.1.0"
    system "git submodule init"
    system "git submodule update"

    Dir.chdir prefix+"/build"
    system "rm -rf #{prefix}/build/*"

    system "#{env_vars} cmake ",
      "-D CMAKE_INSTALL_PREFIX:STRING=#{prefix}",
      "-D CMAKE_C_COMPILER:STRING=cc",
      "-D CMAKE_CXX_COMPILER:STRING=CC",
      "-D CMAKE_Fortran_COMPILER:STRING=ftn",
      "-D MPIEXEC:STRING=aprun",
      "-D MPI_C_COMPILER:STRING=cc",
      "-D MPI_CXX_COMPILER:STRING=CC",
      "-D MPI_Fortran_COMPILER:STRING=ftn",
      "-D Module_vtkPVCatalyst:BOOL=true",
      "-D Module_vtkPVCatalystTestDriver:BOOL=true",
      "-D PARAVIEW_BUILD_CATALYST_ADAPTORS:BOOL=true",
      "-D PARAVIEW_ENABLE_CATALYST:BOOL=true",
      "-D PARAVIEW_ENABLE_PYTHON:BOOL=true",
      "-D PARAVIEW_ENABLE_QT_SUPPORT:BOOL=false",
      "-D PARAVIEW_BUILD_QT_GUI:BOOL=false",
      "-D PARAVIEW_USE_MPI:BOOL=true",
      "-D PYTHON_EXECUTABLE:STRING=/opt/sw/xk6/python/2.7.3/sles11.1_gnu4.3.4/bin/python",
#      "-D PYTHON_INCLUDE_DIR:STRING=/opt/sw/xk6/python/2.7.3/sles11.1_gnu4.3.4/include/python2.7",
#      "-D PYTHON_LIBRARY:STRING=/opt/sw/xk6/python/2.7.3/sles11.1_gnu4.3.4/lib/libpython2.7.so",
#      "-D PYTHON_UTIL_LIBRARY:STRING=",
#      "-D PARAVIEW_FREEZE_PYTHON:BOOL=true",
      "-D VTK_MPIRUN_EXE:STRING=aprun",
      "-D VTK_OPENGL_HAS_OSMESA:BOOL=true",
      "-D VTK_USE_LARGE_DATA:BOOL=true",
      "-D VTK_USE_OFFSCREEN:BOOL=true",
      "-D VTK_USE_X:BOOL=false",
      "-D BUILD_TESTING:BOOL=false",
      "-D OPENGL_gl_LIBRARY:STRING=''",
      "-D BUILD_SHARED_LIBS:BOOL=OFF",
      "-D CMAKE_BUILD_TYPE:STRING=Release",
      "../source"

    system "#{env_vars} make VERBOSE=1 -j1"
    system "#{env_vars} make install"
  end

  modulefile do
  <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    prepend-path PATH $PREFIX/bin
    prepend-path PYTHONPATH $PREFIX/lib/site-packages

  MODULEFILE
  end

end
