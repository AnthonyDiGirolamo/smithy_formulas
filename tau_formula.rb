class TauFormula < Formula
  homepage "http://www.cs.uoregon.edu/research/tau/"
  url "http://www.cs.uoregon.edu/research/tau/tau_releases/tau-2.24.1.tar.gz"
  version "2.24.1"

  # only put non-PrgEnv-dependent modules in depends_on
  #depends_on [ "otf", "pdtoolkit", "libelf", "libdwarf", "boost", "dyninstapi" ]
  depends_on [ "otf", "pdtoolkit" ]

  # NOTE: on Titan, please 'module swap craype-interlagos craype-istanbul' before running 'smithy formula install'
  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")
    commands = [ "unload #{pe}cray #{pe}gnu #{pe}intel #{pe}pgi" ]
    case build_name
    when /cray/
      commands << "load #{pe}cray"
      if build_name =~ /cray([\d\.]+)/
        compiler_module = "cce/#{$1}"
        commands << "swap cce #{compiler_module}" if module_is_available? compiler_module
      end
    when /gnu/
      commands << "load #{pe}gnu"
      if build_name =~ /gnu([\d\.]+)/
        compiler_module = "gcc/#{$1}"
        commands << "swap gcc #{compiler_module}" if module_is_available? compiler_module
      end
    when /intel/
      commands << "load #{pe}intel"
      if build_name =~ /intel([\d\.]+)/
        compiler_module = "intel/#{$1}"
        commands << "swap intel #{compiler_module}" if module_is_available? compiler_module
      end
    when /pgi/
      commands << "load #{pe}pgi"
      if build_name =~ /pgi([\d\.]+)/
        compiler_module = "pgi/#{$1}"
        commands << "swap pgi #{compiler_module}" if module_is_available? compiler_module
      end
    end
    commands << "load cudatoolkit"
    commands << "load papi" if module_is_available?("papi")
  end

  def install
    module_list

    platform = ENV['HOSTNAME']

    # common configuration options
    have_user_flags = 0
    user_flags = ""
    config_args = "./configure -prefix=#{prefix} -mpi -iowrapper"
    config_args << " -otf=#{otf.prefix}"
    config_args << " -pdt=#{pdtoolkit.prefix} -pdt_c++=/opt/gcc/4.9.0/bin/g++"

    if build_name.include?("gnu")
       config_args << " -cc=gcc -c++=g++ -fortran=gnu"
    elsif build_name.include?("intel")
       config_args << " -cc=icc -c++=icpc -fortran=intel"
    elsif build_name.include?("pgi")
       config_args << " -cc=pgcc -c++=pgCC -fortran=pgi"
    elsif build_name.include?("cray")
       config_args << " -cc=cc -c++=CC -fortran=cray"
    end

    if (platform =~ /^eos/) || (platform =~ /^titan/) # Cray platforms
       config_args << " -bfd=download"
       config_args << " -arch=craycnl"

       # use compiler wrappers for MPI builds
       ENV['MPICC'] = "cc"
       ENV['MPICXX'] = "CC"
       ENV['MPIF77'] = "ftn"

#       if build_name.include?("cray")
#          # force Cray compiler into GNU compatibility mode
#          have_user_flags = 1
#          user_flags << " -h gnu"
#       end

       # need CUDA support?
#       if build_name.include?("gpu")
#          config_args << " -cuda=$CUDATOOLKIT_HOME"
#       else
#          config_args << " -DISABLESHARED"
#       end
    end

    # configure for PAPI when available
    if module_is_available?("papi")
       papi_prefix = module_environment_variable("papi", "PATH")
       papi_prefix = File.dirname(papi_prefix)
       config_args << " -papi=#{papi_prefix}"
    end

    # configure for Score-P when available
    if module_is_available?("scorep/.1.4.2")
       scorep_prefix = module_environment_variable("scorep", "SCOREP_DIR")
       config_args << " -scorep=#{scorep_prefix}"
    end

    # configure for libunwind when available
    if module_is_available?("libunwind")
        libunwind_prefix = module_environment_variable("libunwind", "LIBUNWIND_DIR")
        config_args << " -unwind=#{libunwind_prefix}"
    else
        config_args << " -unwind=download"
    end

    # add user flags
    if have_user_flags != 0
       config_args << " -useropt=\'#{user_flags}\'"
    end

    # build for OpenMP, Pthreads and gpu
    openmp_config = "-openmp -opari"
    if build_name.include?("intel")
        openmp_config + " -ompt=download"
    end
    pthread_config = "-pthread"
    gpu_config = "-cuda=$CUDATOOLKIT_HOME"

    system "#{config_args} #{openmp_config} -DISABLESHARED 2>&1 | tee smithy.openmp.cfglog"
    system "(make clean && make all && make install) 2>&1 | tee smithy.openmp.bldlog"

    system "#{config_args} #{pthread_config} -DISABLESHARED  2>&1 | tee smithy.pthread.cfglog"
    system "(make clean && make all && make install) 2>&1 | tee smithy.pthread.bldlog"

    if (platform =~ /^eos/) || (platform =~ /^titan/)
        system "#{config_args} #{openmp_config} #{gpu_config} 2>&1 | tee smithy.openmpi.gpu.cfglog"
        system "(make clean && make all && make install) 2>&1 | tee smithy.openmp.gpu.bldlog"

        system "#{config_args} #{pthread_config} #{gpu_config} 2>&1 | tee smithy.pthread.gpu.cfglog"
        system "(make clean && make all && make install) 2>&1 | tee smithy.pthread.gpu.bldlog"
    end

    # make OpenMP the default TAU config
#    if (platform =~ /^eos/) || (platform =~ /^titan/)
#       system "test -d #{prefix}/craycnl/lib && cd #{prefix}/craycnl/lib && ln -s Makefile.tau-*openmp* Makefile.tau"
#    else
#       system "test -d #{prefix}/x86_64/lib && cd #{prefix}/x86_64/lib && ln -s Makefile.tau-*openmp* Makefile.tau"
#    end
  end

  modulefile do
    <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
        puts stderr "TAU - Tuning and Analysis Utilities"
        puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    # runtime requires otf, papi, pdtoolkit
    module load otf papi pdtoolkit

    # viewers require java
    module load java

    <% if @builds.size > 1 %>
    <%= module_build_list @package, @builds, :prgenv_prefix => #{module_is_available?("PrgEnv-gnu") ? '"PrgEnv-"' : '"PE-"'} %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    <% else %>
    set PREFIX <%= @package.prefix %>
    <% end %>

    set VERSION <%= @package.version %>
    #set ARCH $PREFIX/craycnl
    set ARCH $PREFIX/x86_64
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
end
