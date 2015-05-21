class CubeFwFormula < Formula
  homepage "http://www.scalasca.org/software/cube-4.x/download.html"
  url "http://apps.fz-juelich.de/scalasca/releases/cube/4.3/dist/cube-4.3.tar.gz"
  version "4.3"

  module_commands do
    commands = [ "unload PrgEnv-cray PrgEnv-gnu PrgEnv-intel PrgEnv-pathscale PrgEnv-pgi" ]
    case build_name
    when /cray/
      commands << "load PrgEnv-cray"
      if build_name =~ /cray([\d\.]+)/
        compiler_module = "cce/#{$1}"
        commands << "swap cce #{compiler_module}" if module_is_available? compiler_module
      end
    when /gnu/
      commands << "load PrgEnv-gnu"
      if build_name =~ /gnu([\d\.]+)/
        compiler_module = "gcc/#{$1}"
        commands << "swap gcc #{compiler_module}" if module_is_available? compiler_module
      end
    when /intel/
      commands << "load PrgEnv-intel"
      if build_name =~ /intel([\d\.]+)/
        compiler_module = "intel/#{$1}"
        commands << "swap intel #{compiler_module}" if module_is_available? compiler_module
      end
    when /pgi/
      commands << "load PrgEnv-pgi"
      if build_name =~ /pgi([\d\.]+)/
        compiler_module = "pgi/#{$1}"
        commands << "swap pgi #{compiler_module}" if module_is_available? compiler_module
      end
    end
    #commands << "load java"
  end

  def install
    module_list

    case build_name
      when /pgi/
        system "./configure -prefix=#{prefix} --disable-shared --enable-static --with-frontend-compiler-suite=pgi"
      when /gnu/
        system "./configure -prefix=#{prefix} --disable-shared --enable-static --with-frontend-compiler-suite=gcc"
      when /intel/
        system "./configure -prefix=#{prefix} --disable-shared --enable-static --with-frontend-compiler-suite=intel"
      when /cray/
        system "./configure -prefix=#{prefix} --disable-shared --enable-static"
    end

    system "make"
    system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"
    set ARCH x86_64
    set PREFIX <%= @package.prefix %>
    setenv CUBE_DIR $PREFIX
    setenv CUBE_INC $PREFIX/include
    setenv CUBE_LIB $PREFIX/$ARCH/lib
    prepend-path PATH            $PREFIX/$ARCH/bin
    prepend-path LIBRARY_PATH    $PREFIX/$ARCH/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/$ARCH/lib
  MODULEFILE
end
