class DyninstapiFormula < Formula
  homepage "http://www.dyninst.org"
  url "http://www.dyninst.org/sites/default/files/downloads/dyninst/8.1.2/DyninstAPI-8.1.2.tgz"
  version "8.1.2"

  depends_on [ "boost/1.54.0", "libelf", "libdwarf" ]

  module_commands [
    "unload PrgEnv-cray PrgEnv-gnu PrgEnv-intel PrgEnv-pathscale PrgEnv-pgi",
    "load PrgEnv-gnu",
  ]

  def install
    module_list
    system "cp /sw/sources/powerpc/config.guess autodyninst/config.guess" if build_name.include? "ppc64le"
    config_cmd = [
      "./configure --prefix=#{prefix}",
      "--disable-m32 --disable-testsuite",
      "--with-boost=#{boost.prefix}",
      "--with-libelf=#{libelf.prefix}",
      "--with-libdwarf=#{libdwarf.prefix}",
      "--enable-static",
      "CC=gcc CXX=g++"
    ]
    system config_cmd
    system "make install"
    system "make distclean"
    config_cmd = [
      "./configure --prefix=#{prefix}",
      "--disable-m32 --disable-testsuite",
      "--with-boost=#{boost.prefix}",
      "--with-libelf=#{libelf.prefix}",
      "--with-libdwarf=#{libdwarf.prefix}",
      "CC=gcc CXX=g++"
    ]
    system config_cmd
    system "make install"
    system "make distclean"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    # load the dependencies
    module load libelf libdwarf boost/1.54.0
    prereq libelf libdwarf boost/1.54.0

    set PREFIX <%= @package.prefix %>

    # standard package env vars
    setenv DYNINSTAPI_DIR $PREFIX
    setenv DYNINSTAPI_INC "-I$PREFIX/include"
    setenv DYNINSTAPI_LIB "-L$PREFIX/lib"

    # this env var is expected by many tools built using DyninstAPI
    setenv DYNINST_ROOT $PREFIX

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
                puts stderr "Creating temporary install of DyninstAPI runtime components at $tmpinstall"
                system mkdir -p $tmpinstall/lib
                set dynlibs [ glob -directory $PREFIX/lib *.so* ]
                system cp -a $dynlibs $tmpinstall/lib/
                set dynlibs [ glob -directory $env(LIBELF_DIR)/lib *.so* ] 
                system cp -a $dynlibs $tmpinstall/lib/
                set dynlibs [ glob -directory $env(LIBDWARF_DIR)/lib *.so* ] 
                system cp -a $dynlibs $tmpinstall/lib/
            }
 
            # make sure shared libs can be found be apps
            prepend-path LIBRARY_PATH    $tmpinstall/lib
            prepend-path LD_LIBRARY_PATH $tmpinstall/lib

            # this env var is needed by all DyninstAPI mutatees
            setenv DYNINSTAPI_RT_LIB $tmpinstall/lib/libdyninstAPI_RT.so

        } else { # not in a job

            # this env var is needed by all DyninstAPI mutatees
            setenv DYNINSTAPI_RT_LIB libdyninstAPI_RT.so

        }
    }

  MODULEFILE
end
