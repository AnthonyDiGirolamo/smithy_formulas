class MagmaFormula < Formula
  homepage "http://icl.cs.utk.edu/magma/index.html"
  url "http://icl.cs.utk.edu/projectsfiles/magma/downloads/magma-1.6.2.tar.gz"

  module_commands ["switch PrgEnv-pgi PrgEnv-gnu", "load cudatoolkit", "load acml"]

  def install
    module_list

    patch <<-EOF.strip_heredoc
      diff --git a/make.inc b/make.inc
      new file mode 100644
      index 0000000..8b8cd6a
      --- /dev/null
      +++ b/make.inc
      @@ -0,0 +1,16 @@
      +GPU_TARGET = Kepler
      +CC        = cc -DCUBLAS_GFORTRAN
      +CXX       = CC -DCUBLAS_GFORTRAN
      +NVCC      = nvcc -Xcompiler -fPIC
      +FORT      = ftn -DCUBLAS_GFORTRAN
      +ARCH      = ar
      +ARCHFLAGS = cr
      +RANLIB    = ranlib
      +OPTS      = -O3 -DADD_ -fPIC
      +F77OPTS   = -O3 -DADD_ -fno-second-underscore -fPIC
      +FOPTS     = -O3 -DADD_ -fno-second-underscore -fPIC
      +NVOPTS    = -O3 -DADD_ --compiler-options -fno-strict-aliasing -DUNIX
      +LDOPTS    = -fPIC -Xlinker -zmuldefs -L$(CRAY_CUDATOOLKIT_DIR)/lib64 -L$(CRAY_CUDATOOLKIT_DIR)/extras/CUPTI/lib64 -Wl,--as-needed -Wl,-lcupti -Wl,-lcudart -Wl,--no-as-needed -L/opt/cray/nvidia/default/lib64 -lcuda
      +LIB       =  -lpthread -lcublas -lm -lcupti -lcudart
      +CUDADIR   = $(CRAY_CUDATOOLKIT_DIR)
      +INC       = -I$(CUDADIR)/include
    EOF

    system "export LD_LIBRARY_PATH=/opt/acml/5.3.1/gfortran64/lib/:$LD_LIBRARY_PATH && make"
    system "cd #{prefix} && cp -rv source/include source/lib ./"
  end

proc ModulesHelp { } {
   puts stderr "magma 1.6.2"
   puts stderr ""
}
  modulefile <<-modulefile.strip_heredoc
    #%Module
    proc moduleshelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # one line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    prereq cudatoolkit
    conflict PrgEnv-pathscale PrgEnv-cray PrgEnv-intel

    set PREFIX <%= @package.prefix %>

    prepend-path LD_LIBRARY_PATH  $PREFIX/lib
    prepend-path LIBRARY_PATH     $PREFIX/lib
    prepend-path INCLUDE_PATH     $PREFIX/include

    set MAGMALIB "-L$PREFIX/lib -lmagma -lmagmablas -lcublas"
    prepend-path MAGMA_LIB $MAGMALIB
    set MAGMAINC "-I$PREFIX/include"
    prepend-path MAGMA_INC $MAGMAINC

    setenv       MAGMA_POST_COMPILE_OPTS $MAGMAINC
    setenv       MAGMA_POST_LINK_OPTS    $MAGMALIB
    append-path  PE_PRODUCT_LIST         MAGMA
  modulefile
end
