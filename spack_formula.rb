class SpackFormula < Formula
  homepage "https://software.llnl.gov/spack"
  url "none"
  
  module_commands ["load git"]

  def install
    @prefix = "/sw/#{build_name}"
    system "git clone https://github.com/LLNL/spack.git #{@prefix}" unless Dir.exist? @prefix
    system "mkdir -p #{@prefix}/share/spack/modules/linux-x86_64"
    system "mkdir -p #{@prefix}/share/spack/modules/unknown_arch"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "spack 0.8.15"
       puts stderr ""
    }
    module-whatis "spack 0.8.15"
    prereq python
    
    set PREFIX /sw/<%= @package.build_name %>
    
    setenv       SPACK_ROOT $PREFIX
    prepend-path PATH       $PREFIX/bin
    module use $PREFIX/share/spack/modules/linux-x86_64
    module use $PREFIX/share/spack/modules/unknown_arch
  MODULEFILE
end
