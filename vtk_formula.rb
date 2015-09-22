class VtkFormula < Formula
  homepage "http://www.vtk.org"
  url "http://www.vtk.org/files/release/6.3/VTK-6.3.0.tar.gz"

  module_commands [
    "unload PE-pgi PE-cray PE-intel PE-gnu",
    "load PE-gnu",
    "load git",
    "load cmake",
    "load python",
    "load mesa",
    "load glu"
  ]

  def install
    module_list

    mesa_root = module_environment_variable("mesa", "OSMESA_ROOT")
    glu_root = module_environment_variable("glu", "GLU_ROOT")
    system "cmake",
      "-D CMAKE_INSTALL_PREFIX=#{prefix}",
      "-D CMAKE_C_COMPILER=mpicc",
      "-D CMAKE_CXX_COMPILER=mpic++",
      "-D CMAKE_Fortran_COMPILER=mpif90",
      "-D VTK_RENDERING_BACKEND=OpenGL2",
      "-D VTK_OPENGL_HAS_OSMESA=true",
      "-D OPENGL_INCLUDE_DIR=#{mesa_root}/include",
      "-D OPENGL_gl_LIBRARY=#{mesa_root}/lib/libOSMesa.so",
      "-D OPENGL_glu_LIBRARY=#{glu_root}/lib/libGLU.so",
      "-D VTK_USE_OFFSCREEN=true",
#      "-D Module_vtkIOADIOS=true",
      "-D VTK_USE_X=false",
      "-D BUILD_TESTING=false",
      "-D CMAKE_BUILD_TYPE=Release",
      "-D OSMESA_ROOT=#{mesa_root}",
      "."

    system "make VERBOSE=1"
    system "make install"
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
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
  MODULEFILE
  end

end
