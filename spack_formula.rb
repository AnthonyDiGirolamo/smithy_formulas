class SpackFormula < Formula
  homepage "https://software.llnl.gov/spack"
  url "none"
  
  module_commands ["load git"]

  def is_git_repo?(path)
    Dir.exist?(File.join(path,"/.git"))
  end

  def install
    @prefix = "/sw/#{build_name}/.spack"
    system "mkdir -p #{@prefix}"
    system "git clone https://github.com/LLNL/spack.git #{@prefix}" unless is_git_repo? @prefix
    system "mkdir -p #{@prefix}/share/spack/modules/linux-x86_64"
    system "mkdir -p #{@prefix}/share/spack/modules/unknown_arch"

    #install spack hooks
    @hooksprefix = "/sw/#{build_name}/.spack-hooks"
    if is_git_repo? @hooksprefix
      system "cd #{@hooksprefix}; git pull"
    else
      system "git clone gitlab@gitlab.ccs.ornl.gov:ua/spack-hooks.git #{@hooksprefix}"
    end
    Dir["#{@hooksprefix}/*.py"].each do |hook|
      hook_name = hook.split("/").last
      system "ln #{hook} #{@prefix}/lib/spack/spack/hooks/#{hook_name}"
    end
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "spack 0.8.15"
       puts stderr ""
    }
    module-whatis "spack 0.8.15"
    prereq python
    
    set PREFIX /sw/<%= @package.build_name %>/.spack
    
    setenv       SPACK_ROOT $PREFIX
    prepend-path PATH       $PREFIX/bin
    module use $PREFIX/share/spack/modules/linux-x86_64
    module use $PREFIX/share/spack/modules/unknown_arch
  MODULEFILE
end
