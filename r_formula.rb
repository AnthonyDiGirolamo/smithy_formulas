class RFormula < Formula
  homepage "http://www.r-project.org"
  url "http://mirrors.nics.utk.edu/cran/src/base/R-3/R-3.2.0.tar.gz"
  md5 "66fa17ad457d7e618191aa0f52fc402e"
  
  module_commands [
                   "unload PE-gnu PE-pgi PE-intel PE-cray",
                   "unload r",
                   "load PrgEnv-intel",
                   "load szip",
                   "load acml/5.3.0",
                   "load sprng",
                   "load netcdf-parallel",
                   "load zeromq"
                  ]
  def install
    r_home = "#{prefix}/lib64/R"
    
    confopts = ""
    confopts << " --enable-R-profiling"
    confopts << " --enable-memory-profiling"
    confopts << " --enable-R-shlib"
    confopts << " --enable-BLAS-shlib"
    confopts << " --enable-byte-compiled-packages"
    confopts << " --enable-shared"
    confopts << " --enable-long-double"
    confopts << " --with-readline"
    confopts << " --with-tcltk"
    confopts << " --with-cairo"
    confopts << " --with-libpng"
    confopts << " --with-jpeglib"
    confopts << " --with-libtiff"
    confopts << " --with-system-zlib"
    confopts << " --with-system-bzlib"
    confopts << " --with-system-pcre"
    confopts << " --with-valgrind-instrumentation"
    confopts << " --with-blas"
    confopts << " --with-lapack"
    puts "#{confopts}"
    
    module_list
    system "./configure --prefix=#{prefix} #{confopts}"
    system "make all"
    system "make check"
    system "make install"
    
    # R relies on ISO/IEC 60559 compliance of an external BLAS:
    #      ACML (and MKL) are not compliant so test reg-BLAS.Rout fails in
    #      its handling of NAs: NA * 0 = 0 rather than NA!
    # Two options are available:
    # (1) disable two lines before build as follows:
    #disabled for ACML: stopifnot(identical(z, x %*% t(y)))
    #disabled for ACML: stopifnot(is.nan(log(0) %*% 0))
    # see http://devgurus.amd.com/message/1255852#1255852
    # (2) swap in the library with a symlink after the install:
    if module_is_available?("acml/5.3.0")
      acml_prefix = module_environment_variable("acml/5.3.0", "ACML_DIR")
      acml_lib = "#{acml_prefix}/gfortran64_fma4_mp/lib"
      system "mv #{r_home}/lib/libRblas.so #{r_home}/lib/libRblas.so.keep"
      system "ln -s #{acml_lib}/libacml_mp.so #{r_home}/lib/libRblas.so"
    end

    # Patch rzmq package. Patch needed to find zeromq include and lib.
    #   Didn't work via CPPFLAGS and LD_LIBRARY_PATH, so patching PKG_CPPFLAGS
    #   and PKG_LIBS. There must be an easier way to do this!
    rzmq_file = "rzmq_0.7.7.tar.gz"
    system "wget http://mirrors.nics.utk.edu/cran/src/contrib/#{rzmq_file}"
    zeromq_dir = module_environment_variable("zeromq", "ZEROMQ_DIR")
    system "tar -xvzf #{rzmq_file}"
    # note that ./ path prefix was added in the generated diff file below
    patch <<-EOF.strip_heredoc
      diff -rupN ./rzmq/src/Makevars ./rzmq_p/src/Makevars
      --- ./rzmq/src/Makevars	2014-12-04 11:01:48.000000000 -0500
      +++ ./rzmq_p/src/Makevars	2014-12-04 11:01:48.000000000 -0500
      @@ -1,5 +1,5 @@
       ## -*- mode: makefile; -*-
       
       CXX_STD = CXX11
      -PKG_CPPFLAGS = -I../inst/cppzmq
      -PKG_LIBS = -lzmq
      +PKG_CPPFLAGS = -I../inst/cppzmq -I#{zeromq_dir}/include
      +PKG_LIBS = -L#{zeromq_dir}/lib -lzmq      
    EOF
    
    # Install several optional packages, including pbdR for SPMD:
    File.open("pInstall", "w+") do |f|
      f.write <<-EOF.strip_heredoc
        BP <- function()
          {
            ## set utk.edu mirror repository url
            cm <- getCRANmirrors()
            cran <- cm[grep("utk.edu",cm[,"URL"]),"URL"]
            options(repos=cran)

            ## select CRAN packages to install
            pkgs <- c("evir", "ismev", "maps", "ggplot2", "SuppDists", "doMC",
                      "foreach", "snow", "doSNOW", "diptest", "ncdf4",
                      "devtools", "dplyr", "stringr", "reshape2", "Rmpi")
            rnetcdfdir <- system("echo $NETCDF_DIR", intern=TRUE)
            sprngdir <- system("echo $SPRNG_LIB", intern=TRUE)
            sprngdir <- substr(strsplit(sprngdir, split="/include")[[1]][1],
                               3, stop=1000)
            ompidir <- system("echo $OMPI_DIR", intern=TRUE)
            config <- list(ncdf=paste("--with-nc-config=", rnetcdfdir,
                           "/bin/nc-config", sep=""),
                           rsprng=paste("--with-sprng=", sprngdir, sep=""),
                           Rmpi=paste("--with-Rmpi-type=OPENMPI",
                                      " --with-mpi=", ompidir, sep=""))
            install.packages(pkgs=pkgs, configure.args=config)

            ## install rmzq (for pbdCS) from patched source tree
            install.packages(pkgs="rzmq", repos=NULL)

            ## Now install pbdR packages from GitHub:
            library(devtools)
            install_github(repo="wrathematics/RNACI") 
            install_github(repo="RBigData/pbdMPI") 
            install_github(repo="RBigData/pbdSLAP") 
            #install_github(repo="RBigData/pbdNCDF4") 
            install_github(repo="RBigData/pbdBASE") 
            install_github(repo="RBigData/pbdDMAT") 
            install_github(repo="RBigData/pbdDEMO")
            install_github(repo="wrathematics/pbdCS")
          }
        BP()
      EOF
    end
    system "#{r_home}/bin/Rscript pInstall"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    # R with parallel support
    set rnv <%= @package.name %>/<%= @package.version %>
    set rprefix <%= @package.prefix %>

    if [ is-loaded PE-pathscale ] {
      puts stderr "The pathscale version of $rnv is not available."
      exit
    } elseif [ is-loaded PE-pgi ] {
      puts stderr "The pgi version of $rnv is not available."
      exit
    } elseif [ is-loaded PE-intel ] {
      puts stderr "The intel version of $rnv is not available."
      exit
    } elseif [ is-loaded PE-cray ] {
      puts stderr "The xk6 version of $rnv is not available."
      exit
    } elseif [ is-loaded PE-gnu ] {
      module load acml
      set ompidir {$OMPI_DIR}
      prepend-path PATH             $rprefix/lib64/R/bin
      prepend-path LD_LIBRARY_PATH  $ompidir/lib
      prepend-path LD_LIBRARY_PATH  $rprefix/lib64/R/lib
      prepend-path INCLUDE_PATH     $rprefix/lib64/R/include
      setenv OMP_NUM_THREADS 1
      puts stderr "Parallel Batch Use (see r-pbd.org) via mpirun Rscript."
      puts stderr "OMP_NUM_THREADS set to 1. Change as needed to use ACML."
    } else {
       puts stderr "The current PE version of $rnv is not available."
       exit
    }
  MODULEFILE
end
