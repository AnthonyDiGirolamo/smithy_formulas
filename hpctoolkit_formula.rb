class HpctoolkitFormula < Formula
  homepage "http://hpctoolkit.org"
  url "none"

  module_commands [
    "unload PrgEnv-gnu PrgEnv-pgi PrgEnv-intel PrgEnv-cray",
    "load PrgEnv-gnu",
    "load subversion",
    "load papi",
    "load java",
  ]

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

    Dir.chdir prefix+"/source/hpctoolkit"
    system "./configure --prefix=#{prefix}", 
      "HPC_LT_LDFLAGS='-all-static'",
      "--with-externals=#{prefix}",
      "--with-papi=#{papi_prefix}"
    system "make"
    system "make install"
  end
end
