class GromacsFormula < Formula
  homepage "http://www.gromacs.org"
  url "ftp://ftp.gromacs.org/pub/gromacs/gromacs-5.0.2.tar.gz"
  
#  module_commands ["unload PrgEnv-pgi PrgEnv-gnu PrgEnv-intel PrgEnv-cray","load PrgEnv-gnu","load cudatoolkit","load cmake","load fftw"]
  module_commands ["unload PrgEnv-pgi PrgEnv-gnu PrgEnv-intel PrgEnv-cray","load PrgEnv-gnu","load cudatoolkit","load cmake","load fftw"]

  def install
    module_list
    system "mkdir -p build"
    Dir.chdir("build")

    fftw_lib = (build_name =~ /double/) ? "$FFTW_DIR/libfftw3.a" : "$FFTW_DIR/libfftw3f.a"
    cmake_options = {
      "CMAKE_C_COMPILER"=>"cc", 
      "CMAKE_CXX_COMPILER"=>"CC",
      "GMX_MPI"=>"on",
      "CMAKE_INSTALL_PREFIX"=> prefix, 
      "BUILD_SHARED_LIBS"=>"off",
      "GMX_FFT_LIBRARY"=>"fftw3",
      "FFTWF_LIBRARY"=> fftw_lib,
      "FFTWF_INCLUDE_DIR"=>"$FFTW_INC", 
      "CMAKE_SKIP_RPATH"=>"YES",
      "GMX_GPU"=>"ON",
      "GMX_SIMD"=>"AVX_128_FMA",
      "GMX_USE_RDTSCP"=>"OFF"
    }
    options_string = cmake_options.each_pair.collect{|k,v| "-D#{k}=#{v}"}.join(' ')
    system "cmake .. #{options_string}"
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
