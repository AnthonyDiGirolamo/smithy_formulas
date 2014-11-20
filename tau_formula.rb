class TauFormula < Formula
  homepage "http://www.cs.uoregon.edu/research/tau/"
  url "http://www.cs.uoregon.edu/research/tau/tau_releases/tau-2.22.3b4.tar.gz"
  version "2.22.3"

  depends_on [ "otf", "pdtoolkit", "libelf", "libdwarf", "boost", "dyninstapi" ]

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
    commands << "load cudatoolkit" if build_name =~ /gpu/
    commands << "load papi"
    commands
  end

  def install
    module_list

    papi_prefix = module_environment_variable("papi", "PATH")
    papi_prefix = File.dirname(papi_prefix)

    config_args = [
      "./configure -prefix=#{prefix} -arch=craycnl -mpi -bfd=download -iowrapper",
      "-dyninst=#{dyninstapi.prefix} -dwarf=#{libdwarf.prefix}",
      "-otf=#{otf.prefix} -papi=#{papi_prefix}",
      "-pdt=#{pdtoolkit.prefix} -pdt_c++=g++"
    ]
    # which thread package? openmp or pthread
    if build_name.include?("openmp")
      config_args << "-openmp -opari"
    else
      config_args << "-pthread"
    end
    # need CUDA support?
    if build_name.include?("gpu")
      config_args << "-cuda=$CUDATOOLKIT_HOME"
    end
    # eos uses mpich 3.x
    if ENV['HOSTNAME'] =~ /^eos/
      config_args << "-useropt=\"-I#{libelf.prefix}/include -I#{boost.prefix}/include -I#{dyninstapi.prefix}/include -DTAU_MPICH3\""
    else
      config_args << "-useropt=\"-I#{libelf.prefix}/include -I#{boost.prefix}/include -I#{dyninstapi.prefix}/include\""
    end

    if build_name.include?("cray")
      ENV['CC'] = "gcc"
      ENV['CXX'] = "g++"
      ENV['F77'] = "ftn"
      ENV['F90'] = "ftn"
      ENV['FC'] = "ftn"
    elsif build_name.include?("gnu")
      ENV['CC'] = "gcc"
      ENV['CXX'] = "g++"
      ENV['F77'] = "gfortran"
      ENV['F90'] = "gfortran"
      ENV['FC'] = "gfortran"
    elsif build_name.include?("intel")
      ENV['CC'] = "icc"
      ENV['CXX'] = "icpc"
      ENV['F77'] = "ifort"
      ENV['F90'] = "ifort"
      ENV['FC'] = "ifort"
    elsif build_name.include?("pgi")
      ENV['CC'] = "pgcc"
      ENV['CXX'] = "pgCC"
      ENV['F77'] = "pgf77"
      ENV['F90'] = "pgf90"
      ENV['FC'] = "pgf90"
    end
    ENV['MPICC'] = "cc"
    ENV['MPICXX'] = "CC"
    ENV['MPIF77'] = "ftn"

    system config_args
    system "make all"
    system "make install"
    system "cd #{prefix}/craycnl/lib && ln -s Makefile.tau-* Makefile.tau"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
        puts stderr "TAU - Tuning and Analysis Utilities"
        puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    # runtime requires otf, papi, pdtoolkit
    module load otf papi pdtoolkit
    prereq otf papi pdtoolkit

    # viewers require java
    module load java
    prereq java

    if [ is-loaded PrgEnv-gnu ] { 
      if [ is-loaded gcc/4.7.2 ] {
        set BUILD_PE gnu4.7.2
      } elseif [ is-loaded gcc/4.8.1 ] {
        set BUILD_PE gnu4.8.1
      }
    } elseif [ is-loaded PrgEnv-pgi ] { 
      if [ is-loaded pgi/12.10.0 ] {
        set BUILD_PE pgi12.10.0
      } elseif [ is-loaded pgi/13.7.0 ] {
        set BUILD_PE pgi13.7.0
      }
    } elseif [ is-loaded PrgEnv-intel ] { 
      if [ is-loaded intel/12.1.3.293 ] {
        set BUILD_PE intel12.1.3.293
      } elseif [ is-loaded intel/13.1.3.192 ] {
        set BUILD_PE intel13.1.3.192
      }
    } elseif [ is-loaded PrgEnv-cray ] { 
      if [ is-loaded cce/8.1.4 ] {
        set BUILD_PE cray8.1.4
      } elseif [ is-loaded cce/8.1.9 ] {
        set BUILD_PE cray8.1.9
      }
    }
    if {![info exists BUILD_PE]} {
      puts stderr "[module-info name] not available for current programming environment"
      break
    }
    set BUILD $BUILD_PE
    <% if @package.build_name =~ /openmp/ %>
    set BUILD ${BUILD}_openmp
    <% end %>
    <% if @package.build_name =~ /gpu/ %>
    set BUILD ${BUILD}_gpu
    <% end %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    set ARCH $PREFIX/craycnl
    set LIBS $ARCH/lib

    # environ setup
    setenv TAU_MAKEFILE $LIBS/Makefile.tau
    setenv TAU_DIR      $PREFIX
    setenv TAU_INC      $PREFIX/include
    setenv TAU_LIB      $LIBS

    # path updates
    prepend-path PATH            $ARCH/bin
    prepend-path MANPATH         $PREFIX/man
    prepend-path LIBRARY_PATH    $LIBS
    prepend-path LD_LIBRARY_PATH $LIBS
  MODULEFILE
end
