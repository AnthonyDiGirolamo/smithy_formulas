class GromacsFormula < Formula
  homepage "http://www.gromacs.org"
  url "ftp://ftp.gromacs.org/pub/gromacs/gromacs-4.6.6.tar.gz"
  
  module_commands ["unload PrgEnv-pgi PrgEnv-gnu PrgEnv-intel PrgEnv-cray","load PrgEnv-gnu","load cudatoolkit","load cmake"]

  def install
    module_list
    system "mkdir -p build"
    Dir.chdir("build")

    cmake_options = {
      "GMX_BUILD_OWN_FFTW"=>"ON",
      "GMX_GPU"=>"ON",
      "GMX_MPI"=>"ON",
      "CUDA_TOOLKIT_ROOT_DIR"=>"$CRAY_CUDATOOLKIT_DIR",
      "BUILD_SHARED_LIBS"=>"OFF",
      "GMX_PREFER_STATIC_LIBS"=>"ON",
      "CMAKE_INSTALL_PREFIX" => prefix,
      "CMAKE_C_COMPILER" => "cc",
      "CUDA_NVCC_HOST_COMPILER" => "g++"
    } 
    options_string = cmake_options.each_pair.collect{|k,v| "-D#{k}=#{v}"}.join(' ')
    system "CC=cc CXX=CC CMAKE_C_COMPILER=cc cmake #{options_string} .."
    system "make"
    system "make install"
  end
  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    # gromacs, Science Apps-Molecular Dynamics
    
    proc ModulesHelp { } {
       puts stderr "Sets up environment for Gromacs <%= @package.version %>"
       puts stderr "Usage:   qsub -V (PBS SCRIPT)"
       puts stderr "         aprun -n (cores) -N (cores per node) (mdrun || mdrun_d) (mdrun options)"
    }
    module-whatis "Sets up environment for Gromacs <%= @package.version %>"
    
    set PREFIX <%= @package.prefix %>
    prepend-path PATH $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path MANPATH $PREFIX/share/man
    setenv GMXDATA $PREFIX/share
    setenv GMXFONT 10x20

  MODULEFILE
end
