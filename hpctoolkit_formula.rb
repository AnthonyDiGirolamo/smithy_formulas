class HpctoolkitFormula < Formula
  homepage "http://hpctoolkit.org"
  url "none"

  module_commands do
    commands = [
      "unload PrgEnv-gnu PrgEnv-pgi PrgEnv-intel PrgEnv-cray",
      "load PrgEnv-gnu",
      "load subversion",
      "load papi/5.1.0.2",
      "load java",
    ]
    commands << "cudatoolkit" if build_name.include? "cuda"
    commands
  end

  def install
    module_list

    ENV['MPICC']  = "cc"
    ENV['MPICXX'] = "CC"
    ENV['MPIF77'] = "ftn"
    ENV['CC']     = "gcc"
    ENV['CXX']    = "g++"

    FileUtils.mkdir_p "source"
    Dir.chdir prefix+"/source"
    system "svn co http://hpctoolkit.googlecode.com/svn/externals hpctoolkit-externals" unless Dir.exists?("hpctoolkit-externals")
    system "svn co http://hpctoolkit.googlecode.com/svn/trunk hpctoolkit" unless Dir.exists?("hpctoolkit")

    Dir.chdir prefix+"/source/hpctoolkit-externals"
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"

    papi_prefix = module_environment_variable("papi", "PATH")
    papi_prefix = File.dirname(papi_prefix)

    notice "PAPI DIR = " + papi_prefix

    Dir.chdir prefix+"/source/hpctoolkit"

    config_args = [
      "./configure --prefix=#{prefix}",
      "HPC_LT_LDFLAGS='-all-static -L../../lib/stubs-gcc_s'",
      "--with-externals=#{prefix}",
      "--with-papi=#{papi_prefix}",
      "--enable-xop"
    ]
    if build_name.include?("cuda")
      config_args << "--with-cuda=$CUDATOOLKIT_HOME"
      config_args << "--enable-papi-c"
    end

    system config_args
    system "make"
    system "make install"

    Dir.chdir prefix
    files = Dir.glob("*")
    files.delete("source")
    files.delete("hpctoolkit-install.tar.gz")
    system "tar cf hpctoolkit-install.tar " + files.join(' ')
    system "gzip hpctoolkit-install.tar"
  end

  modulefile <<-EOF.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "HPCToolkit - sampling-based parallel program profiling and tracing"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    # runtime requires papi
    module load papi
    prereq papi

    # viewers require java
    module load java
    prereq java

    if [ is-loaded cudatoolkit ] {
      set build cle4.1_gnu4.7.2_papi5.1.0.2_cuda5.0.35.102
    } else {
      set build cle4.1_gnu4.7.2_papi5.1.0.2
    }
    set PREFIX <%= @package.version_directory %>/$build

    # temporary install to lustre for runtime libs
    set tmpinstall_hpctk /tmp/work/$env(USER)/.hpctk_install/$env(PE_ENV)

    # environ setup
    setenv HPCTOOLKIT      $tmpinstall_hpctk
    setenv HPCRUN_TMPDIR   /tmp/scratch

    # path updates
    prepend-path PATH            $tmpinstall_hpctk/bin
    prepend-path PATH            $PREFIX/bin
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path LD_LIBRARY_PATH $tmpinstall_hpctk/lib/hpctoolkit
    prepend-path LD_LIBRARY_PATH $PREFIX/lib/hpctoolkit
    # likely not necessary
    #prepend-path LD_LIBRARY_PATH $tmpinstall_hpctk/lib/hpctoolkit/plugins
    #prepend-path LD_LIBRARY_PATH $PREFIX/lib/hpctoolkit/plugins

    # Helpful ENV Vars
    setenv HPCTOOLKIT_DIR $PREFIX
    setenv HPCTOOLKIT_BIN $PREFIX/bin
    setenv HPCTOOLKIT_LIB "-L$PREFIX/lib/hpctoolkit"
    setenv HPCTOOLKIT_INC "-I$PREFIX/include"

    # Only execute file transfer on load/switch2
    if { [ module-info mode load ] || [ module-info mode switch2 ] } {
        puts stderr "Copying runtime support for HPCToolkit to $tmpinstall_hpctk ..."
        # cleanup old stuff
        system test -d $tmpinstall_hpctk && rm -rf $tmpinstall_hpctk
        # copy the libs
        system mkdir -p $tmpinstall_hpctk && cd $tmpinstall_hpctk && tar zxf $PREFIX/hpctoolkit-install.tar.gz
    }
  EOF
end
