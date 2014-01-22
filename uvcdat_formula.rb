class UvcdatFormula < Formula
  homepage "http://uv-cdat.org/"
  url "none"

  depends_on [
    "qt4/4.8.5",
    "sqlite"
    # "cmake/2.8.11.2",
    # "openssl/1.0.1e",
  ]

  module_commands [
    "unload PE-gnu PE-pgi PE-intel PE-cray",
    # "load PE-gnu",
    "load cmake/2.8.11.2",
    "load git",
    "unload gcc"
    # "swap gcc gcc/4.7.1",
  ]

  def install
    module_list
    system "which gcc"

    ENV["CC"]  = "gcc"
    ENV["CXX"] = "g++"
    ENV["F77"] = "gfortran"
    ENV["F90"] = "gfortran"
    ENV["FC"]  = "gfortran"

    FileUtils.mkdir_p "build"
    system "git clone https://github.com/UV-CDAT/uvcdat.git source" unless Dir.exists?("source")

    Dir.chdir prefix+"/source"
    system "git reset --hard"
    system "git pull origin master"
    system "git checkout master"

    # remove bad submodule
    system "git rm --cached contrib/windfield"
    system "git config -f .git/config --remove-section submodule.contrib/windfield ; exit 0"
    system "git config -f .gitmodules --remove-section submodule.contrib/windfield ; exit 0"

    system "git submodule update --init"

    system "git checkout CMake/cdat_modules/cdat_external.cmake"
    system "git checkout CMake/cdat_modules/cairo_external.cmake"

    patch <<-EOF.strip_heredoc
      diff --git a/CMake/cdat_modules/cairo_external.cmake b/CMake/cdat_modules/cairo_external.cmake.fix
      index ed642ea..346d389 100644
      --- a/CMake/cdat_modules/cairo_external.cmake
      +++ b/CMake/cdat_modules/cairo_external.cmake.fix
      @@ -1,7 +1,7 @@

       set(Cairo_source "${CMAKE_CURRENT_BINARY_DIR}/build/Cairo")
       set(Cairo_install "${cdat_EXTERNALS}")
      -set(Cairo_conf_args --disable-static^^--enable-xlib=no^^--enable-xcb=no^^--enable-qt=no^^--enable-quartz=no^^--enable-win32=no^^--enable-skia=no^^--enable-os2=no^^--enable-beos=no^^--enable-drm=no^^--enable-gallium=no^^--enable-gl=no^^--enable-glesv2=no^^--enable-cogl=no^^--enable-directfb=no^^--enable-vg=no)
      +set(Cairo_conf_args --enable-shared^^--enable-gobject=no^^--disable-static^^--enable-xlib=no^^--enable-xcb=no^^--enable-qt=no^^--enable-quartz=no^^--enable-win32=no^^--enable-skia=no^^--enable-os2=no^^--enable-beos=no^^--enable-drm=no^^--enable-gallium=no^^--enable-gl=no^^--enable-glesv2=no^^--enable-cogl=no^^--enable-directfb=no^^--enable-vg=no)

       ExternalProject_Add(Cairo
         LIST_SEPARATOR ^^
    EOF

    patch <<-EOF.strip_heredoc
      diff --git a/CMake/cdat_modules/cairo_external.cmake b/CMake/cdat_modules/cairo_external.cmake
      diff --git a/CMake/cdat_modules/cdat_external.cmake b/CMake/cdat_modules/cdat_external.cmake
      index 71458ef..7634445 100644
      --- a/CMake/cdat_modules/cdat_external.cmake
      +++ b/CMake/cdat_modules/cdat_external.cmake
      @@ -15,7 +15,7 @@ if(APPLE)
         set(qt_flags "--enable-qt-framework")
       endif()

      -set(qt_flags "${qt_flags} --with-qt=${QT_ROOT} --with-qt-lib=${QT_LIB_DIR} --with-qt-inc=${QT_INC_DIR}" --with-qt-bin=${QT_BINARY_DIR})
      +set(qt_flags "${qt_flags} --with-qt=#{qt4.prefix} --with-qt-lib=#{qt4.prefix}/lib --with-qt-inc=#{qt4.prefix}/include" --with-qt-bin=#{qt4.prefix}/bin)

       if (CDAT_BUILD_WITH_LIBDRS)
        set(qt_flags "${qt_flags} -c pcmdi.py")
    EOF

    Dir.chdir prefix
    FileUtils.mkdir_p "Externals/bin"
    FileUtils.mkdir_p "Externals/include"
    FileUtils.mkdir_p "Externals/lib/pkgconfig"
    FileUtils.mkdir_p "Externals/share/man/man1"
    # MyProxyClient installs PyOpenSSL which requires at least OpenSSL 0.9.8f
    # openssl_files = %w{
    #   include/openssl
    #   lib/pkgconfig/libcrypto.pc
    #   lib/pkgconfig/libssl.pc
    #   lib/pkgconfig/openssl.pc
    #   lib/engines
    #   lib/libcrypto.a
    #   lib/libcrypto.so
    #   lib/libcrypto.so.1.0.0
    #   lib/libssl.a
    #   lib/libssl.so
    #   lib/libssl.so.1.0.0
    # }
    # openssl_files.each do |file|
    #   system "ln -sf #{openssl.prefix}/#{file} #{prefix}/Externals/#{file}"
    # end

    Dir.chdir prefix
    sqlite3_files = %w{
      bin/sqlite3
      include/sqlite3.h
      include/sqlite3ext.h
      lib/libsqlite3.so.0.8.6
      lib/libsqlite3.so.0
      lib/libsqlite3.so
      lib/libsqlite3.la
      lib/libsqlite3.a
      lib/pkgconfig/sqlite3.pc
      share/man/man1/sqlite3.1
    }
    sqlite3_files.each do |file|
      FileUtils.mkdir_p File.dirname(file)
      system "ln -sf #{sqlite.prefix}/#{file} #{prefix}/Externals/#{file}"
    end

    Dir.chdir prefix+"/build"
    system "unset PYTHONPATH ; cmake",
      "-D CMAKE_INSTALL_PREFIX:STRING=#{prefix}",
      # "-D CDAT_ANONYMOUS_LOG:STRING=OFF",
      "-D MD5_EXECUTABLE:STRING=md5sum",
      "-D GIT_PROTOCOL:STRING=http://",
      "-D QT_QMAKE_EXECUTABLE:STRING=#{qt4.prefix}/bin/qmake",
      "-D QT_QTCORE_INCLUDE_DIR:STRING=#{qt4.prefix}/include",
      "-D QT_QTCORE_LIBRARY:STRING=#{qt4.prefix}/lib",
      # "-D PYTHON_EXECUTABLE:STRING=#{python.prefix}/bin/python",
      # "-D PYTHON_LIBRARY_DIR:STRING=#{python.prefix}/lib",
      # "-D CDAT_USE_SYSTEM_PYTHON:BOOL=true",
      "-D CDAT_USE_SYSTEM_MPI:BOOL=false",
      "-D CDAT_BUILD_MPI:BOOL=true",
      "-D cdat_build_internal_MPI:BOOL=true",
      "-D CDAT_BUILD_GUI:BOOL=true",
      "-D CDAT_BUILD_GRAPHICS:BOOL=true",
      "-D CDAT_BUILD_PARALLEL:BOOL=true",
      "-D CDAT_BUILD_VISIT:BOOL=true",
      "-D cdat_build_internal_VISIT:BOOL=true",
      # "-D CMAKE_C_COMPILER:STRING=/opt/gcc/4.7.2/bin/gcc",
      # "-D CMAKE_CXX_COMPILER:STRING=/opt/gcc/4.7.2/bin/g++",
      # "-D CMAKE_Fortran_COMPILER:STRING=/opt/gcc/4.7.2/bin/gfortran",
      # "-D MPI_C_COMPILER:STRING=cc",
      # "-D MPI_CXX_COMPILER:STRING=CC",
      # "-D MPI_Fortran_COMPILER:STRING=ftn",
      # "-D CDAT_BUILD_HDF5:BOOL=false",
      # "-D CDAT_BUILD_NETCDF:BOOL=false",
      # "-D CDAT_BUILD_IPYTHON:BOOL=false",
      # "-D CDAT_BUILD_NUMPY:BOOL=false",
      # "-D CDAT_BUILD_MPI:BOOL=false",
      # "-D CDAT_BUILD_MPI4PY:BOOL=false",
      "-D MPIEXEC:STRING=mpiexec",
      # "-D MPI_CXX_COMPILE_FLAGS:STRING=-I/opt/cray/mpt/5.6.3/gni/mpich2-gnu/47/include",
      # "-D MPI_CXX_LINK_FLAGS:STRING='-L/opt/cray/mpt/5.6.3/gni/mpich2-gnu/47/lib -lmpichcxx_gnu_47 -lmpich_gnu_47'",
      # "-D MPI_CXX_INCLUDE_PATH:STRING=aprun",
      # "-D MPI_CXX_LIBRARIES:STRING=aprun",
      # "-D MPI_CXX_COMPILE_FLAGS:STRING=-I/opt/cray/mpt/5.6.3/gni/mpich2-gnu/47/include",
      # "-D MPI_CXX_LINK_FLAGS:STRING='-L/opt/cray/mpt/5.6.3/gni/mpich2-gnu/47/lib -lmpichcxx_gnu_47 -lmpich_gnu_47'",
      # "-D MPI_C_COMPILE_FLAGS:STRING=-I/opt/cray/mpt/5.6.3/gni/mpich2-gnu/47/include",
      # "-D MPI_C_LINK_FLAGS:STRING='-L/opt/cray/mpt/5.6.3/gni/mpich2-gnu/47/lib -lmpich_gnu_47'",
      # "-D MPI_Fortran_COMPILE_FLAGS:STRING=-I/opt/cray/mpt/5.6.3/gni/mpich2-gnu/47/include",
      # "-D MPI_Fortran_LINK_FLAGS:STRING='-L/opt/cray/mpt/5.6.3/gni/mpich2-gnu/47/lib -lmpichf90_gnu_47 -lmpich_gnu_47 -lmpichf90_gnu_47'",
      "../source"

    system "make"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    prepend-path PATH $PREFIX/bin
    prepend-path PATH $PREFIX/Externals/bin
    prepend-path PATH $PREFIX/Library/Frameworks/Python.framework/Versions/2.7/bin

    prepend-path LD_LIBRARY_PATH /sw/analysis-x64/qt/4.8.5/centos5.9_gnu4.1.2/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib/paraview-3.11
    prepend-path LD_LIBRARY_PATH $PREFIX/Externals/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/Externals/lib/R/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib/VisIt-2.6.0

    prepend-path PYTHONPATH $PREFIX/lib/python2.7/site-packages
    prepend-path PYTHONPATH $PREFIX/Externals/lib
    prepend-path PYTHONPATH $PREFIX/lib/VisIt-2.6.0/site-packages

    setenv VISITPLUGINDIR       $PREFIX/lib/VisIt-2.6.0-plugins
    setenv R_HOME               $PREFIX/Externals/lib/R
    setenv LIBOVERLAY_SCROLLBAR 0
  MODULEFILE
end
