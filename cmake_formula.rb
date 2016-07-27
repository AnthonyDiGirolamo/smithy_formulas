class CmakeFormula < Formula
  homepage "http://www.cmake.org/"
  url      "http://www.cmake.org/files/v3.5/cmake-3.5.0.tar.gz"

  module_commands [ "purge" ]

  def install
    module_list

    system "./bootstrap --prefix=#{prefix} --no-qt-gui"
    system "make all"
    system "make install"

    Dir.chdir prefix
    patch <<-EOF.strip_heredoc
      diff --git a/share/cmake-3.5/Modules/Platform/Linux-Intel.cmake.original b/share/cmake-3.5/Modules/Platform/Linux-Intel
      index 2394f10..ad2c75a 100644
      --- a/share/cmake-3.5/Modules/Platform/Linux-Intel.cmake.original
      +++ b/share/cmake-3.5/Modules/Platform/Linux-Intel.cmake
      @@ -38,7 +38,8 @@ macro(__linux_compiler_intel lang)

         # We pass this for historical reasons.  Projects may have
         # executables that use dlopen but do not set ENABLE_EXPORTS.
      -  set(CMAKE_SHARED_LIBRARY_LINK_${lang}_FLAGS "-rdynamic")
      +  # set(CMAKE_SHARED_LIBRARY_LINK_${lang}_FLAGS "-rdynamic")
      +  set(CMAKE_SHARED_LIBRARY_LINK_${lang}_FLAGS "")

         if(XIAR)
           # INTERPROCEDURAL_OPTIMIZATION
    EOF
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
      puts stderr "<%= @package.name %> <%= @package.version %>"
      puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    prepend-path PATH      $PREFIX/bin
    prepend-path MANPATH   $PREFIX/share/man
  MODULEFILE
end
