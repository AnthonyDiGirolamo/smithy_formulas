class NamdFormula < Formula
  homepage "https://www-s.ks.uiuc.edu/Research/namd/"
  url "http://www.ks.uiuc.edu/Research/namd/2.10b1/download/832984/NAMD_2.10b1_Source.tar.gz"

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    commands << "load #{pe}gnu"
    commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
    commands << "load cudatoolkit"
    commands << "load fftw"
    commands << "load rca"
    commands << "load craype-hugepages8M"

    commands
  end

  def install
    module_list

    mpicxx = module_is_available?("PrgEnv-gnu") ? "CC" : "mpicxx"
    namd_arch = module_is_available?("PrgEnv-gnu") ? "CRAY-XE-gnu" : "Linux-x86_64-g++"
    charm = "charm-6.6.0-rc4"

    # Charm++
    system "rm -rf #{charm} ; tar xf #{charm}.tar"
    Dir.chdir charm
    system "env MPICXX=#{mpicxx} ./build charm++ gemini_gni-crayxe persistent smp --no-build-shared --with-production"
    Dir.chdir prefix + "/source"

    # Download tcl
    system "wget http://www.ks.uiuc.edu/Research/namd/libraries/tcl8.5.9-linux-x86_64.tar.gz"
    system "wget http://www.ks.uiuc.edu/Research/namd/libraries/tcl8.5.9-linux-x86_64-threaded.tar.gz"
    system "tar xzf tcl8.5.9-linux-x86_64.tar.gz"
    system "tar xzf tcl8.5.9-linux-x86_64-threaded.tar.gz"
    system "mv tcl8.5.9-linux-x86_64 tcl"
    system "mv tcl8.5.9-linux-x86_64-threaded tcl-threaded"

    # Config
    system "./config #{namd_arch} Titan --charm-arch gemini_gni-crayxe-persistent-smp --with-fftw3 --with-cuda"
    Dir.chdir namd_arch
    system "make"
    system "make release"
    system "mv NAMD_2.10b1_CRAY-XE-ugni-smp-Titan-CUDA/lib ../../lib"
    system "mv NAMD_2.10b1_CRAY-XE-ugni-smp-Titan-CUDA ../../bin"
  end

  modulefile <<-EOF.strip_heredoc
    #%Module
    proc ModulesHelp { } {
      puts stderr "NAMD - Molecular Dynamics"
      puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    prepend-path PATH $PREFIX/bin
  EOF
end
