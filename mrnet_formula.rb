class MrnetFormula < Formula
  homepage "http://www.dyninst.org/mrnet"
  url "ftp://ftp.cs.wisc.edu/paradyn/mrnet/mrnet_4.1.0.tar.gz"
  version "4.1.0"

  depends_on do
     if module_is_available?("boost")
        [ "boost/1.54.0" ]
     else
        [ ]
     end
  end

  module_commands do
     pe = "PE-"
     pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu") 
     commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ] 
     commands << "load #{pe}gnu"
     commands
  end

  def install
     module_list

     # common configuration options
     config_cmd = [
       "./configure", 
       "--prefix=#{prefix}",
       "--enable-shared",
       "--enable-ltwt-threadsafe"
     ]

     if module_is_available?("boost")
        config_cmd << "--with-boost=#{boost.prefix}"
     end

     currhost = ENV['HOSTNAME']

     # check for Cray systems
     its_a_cray = 0
     if currhost =~ /^eos/ or currhost =~ /^titan/
        # use --host to avoid configure execution checks that fail in cross-compile environ
        # and enable Cray startup mode
        config_cmd << "--host=x86_64-cray-linux --with-startup=cray"
        its_a_cray = 1
     end

     # system-specific configuration options
     if currhost =~ /^eos/
        alpsdir = "/opt/cray/alps/default"
        config_cmd << "--with-alpstoolhelp-inc=#{alpsdir}/include --with-alpstoolhelp-lib=#{alpsdir}/lib64"
     elsif currhost =~ /^titan/
        sysroot = ENV['SYSROOT_DIR']
        config_cmd << "--with-alpstoolhelp-inc=#{sysroot}/usr/include --with-alpstoolhelp-lib=#{sysroot}/usr/lib/alps"
        config_cmd << "CFLAGS=-march=amdfam10 CXXFLAGS=-march=amdfam10 LDFLAGS=-L#{sysroot}/usr/lib64"
     end

     # last but not least, always use gcc/g++ directly (i.e., no Cray/MPI compiler wrappers)
     config_cmd << "CC=gcc CXX=g++"

     # configure it already
     system config_cmd

     # build time
     if its_a_cray == 1
        # workaround alternate host build platform
        Dir.chdir prefix+"/source/build/x86_64-cray-linux-gnu" 
     end
     system "make && make tests && make examples && make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
        puts stderr "<%= @package.name %> <%= @package.version %>"
        puts stderr "MRNet: A Multicast/Reduction Network"
        puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    if { [ module avail boost ] } {
        # load the dependencies
        module load boost/1.54.0
    }

    set PREFIX <%= @package.prefix %>

    # standard package env vars
    setenv MRNET_DIR $PREFIX
    setenv MRNET_INC "-I$PREFIX/include"
    setenv MRNET_LIB "-L$PREFIX/lib"

    prepend-path PATH            $PREFIX/bin
    prepend-path LIBRARY_PATH    $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib

    if { [ module-info mode load ] } {
        if [info exists env(PBS_JOBID)] { # in a batch/interactive job
           
            # get project name
            set jobid $env(PBS_JOBID)
            set projid [ exec qstat -f $jobid | awk {/Account_Name = / {print tolower($3)}} ] 

            # create temporary install
            set tmpinstall $env(MEMBERWORK)/$projid/.<%= @package.name %>-<%= @package.version %>
            if { ! [file isdirectory $tmpinstall] } { 
                puts stderr "Creating temporary install of MRNet runtime components at $tmpinstall"
                system mkdir -p $tmpinstall/bin $tmpinstall/lib
                set exes [ glob -directory $PREFIX/bin mrnet_* ]
                system cp -a $exes $tmpinstall/bin/
                set dynlibs [ glob -directory $PREFIX/lib *.so* ]
                system cp -a $dynlibs $tmpinstall/lib/
            }
 
            # make sure shared libs can be found by apps
            prepend-path PATH            $tmpinstall/bin
            prepend-path LIBRARY_PATH    $tmpinstall/lib
            prepend-path LD_LIBRARY_PATH $tmpinstall/lib

            # this env var is needed by all MRNet-based apps/tools
            setenv MRNET_COMM_PATH $tmpinstall/bin/mrnet_commnode

        } 
    }

  MODULEFILE
end
