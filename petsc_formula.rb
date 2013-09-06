class PetscFormula < Formula
  homepage "http://www.mcs.anl.gov/petsc/index.html"
  url "http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.4.2.tar.gz"

  module_commands do
    commands = [ "unload PrgEnv-gnu PrgEnv-intel PrgEnv-pathscale PrgEnv-pgi pgi netcdf hdf5" ]
    case build_name
    when /pgi/
      commands << "load PrgEnv-pgi"
      if build_name =~ /pgi([\d\.]+)/
        compiler_module = "pgi/#{$1}"
        commands << "swap pgi #{compiler_module}" if module_is_available? compiler_module
      end
    when /gnu/
      commands << "load PrgEnv-gnu"
      if build_name =~ /gnu([\d\.]+)/
        compiler_module = "gcc/#{$1}"
        commands << "swap gcc #{compiler_module}" if module_is_available? compiler_module
      end
    when /intel/
      commands << "load PrgEnv-intel"
      if build_name =~ /intel([\d\.]+)/
        compiler_module = "intel/#{$1}"
        commands << "swap intel #{compiler_module}" if module_is_available? compiler_module
      end
    end
    commands << "load acml"
    commands << "load cmake"
    commands << "load cray-hdf5"
    commands << "load cray-tpsl"
    commands
  end

  def install
    ENV['PETSC_DIR'] = prefix+"/source"

    acml_dir        = module_environment_variable("acml",        "ACML_DIR")
    cray_tpsl_dir   = module_environment_variable("cray-tpsl",   "CRAY_TPSL_PREFIX_DIR")
    cray_mpich2_dir = module_environment_variable("cray-mpich2", "CRAY_MPICH2_DIR")
    hdf5_dir        = module_environment_variable("cray-hdf5",   "HDF5_DIR")

    case build_name
    when /gnu/
      blaslapack = "#{acml_dir}/gfortran64/lib/libacml.a"

      sundials_libs = [
        "#{cray_tpsl_dir}/lib/libsundials_cvode_gnu.a",
        "#{cray_tpsl_dir}/lib/libsundials_cvodes_gnu.a",
        "#{cray_tpsl_dir}/lib/libsundials_ida_gnu.a",
        "#{cray_tpsl_dir}/lib/libsundials_idas_gnu.a",
        "#{cray_tpsl_dir}/lib/libsundials_kinsol_gnu.a",
        "#{cray_tpsl_dir}/lib/libsundials_nvecparallel_gnu.a",
        "#{cray_tpsl_dir}/lib/libsundials_nvecserial_gnu.a"
      ]

      sundials_options = "'--with-sundials-include=#{cray_tpsl_dir}/include', '--with-sundials-lib=#{sundials_libs.join(', ')}',"
      mumps_options    = "'--download-mumps',"
      pthread_options  = "'--with-pthreadclasses', '--with-pthread-dir=/usr',"
    when /pgi/
      blaslapack = "#{acml_dir}/pgi64/lib/libacml.a"

      sundials_libs = [
        "#{cray_tpsl_dir}/lib/libsundials_cvode_pgi.a",
        "#{cray_tpsl_dir}/lib/libsundials_cvodes_pgi.a",
        "#{cray_tpsl_dir}/lib/libsundials_ida_pgi.a",
        "#{cray_tpsl_dir}/lib/libsundials_idas_pgi.a",
        "#{cray_tpsl_dir}/lib/libsundials_kinsol_pgi.a",
        "#{cray_tpsl_dir}/lib/libsundials_nvecparallel_pgi.a",
        "#{cray_tpsl_dir}/lib/libsundials_nvecserial_pgi.a"
      ]

      sundials_options = "'--with-sundials-include=#{cray_tpsl_dir}/include', '--with-sundials-lib=#{sundials_libs.join(', ')}',"

      mumps_libs = [
        "#{cray_tpsl_dir}/lib/libcmumps_pgi.a",
        "#{cray_tpsl_dir}/lib/libptesmumps_pgi.a",
        "#{cray_tpsl_dir}/lib/libdmumps_pgi.a",
        "#{cray_tpsl_dir}/lib/libsmumps_pgi.a",
        "#{cray_tpsl_dir}/lib/libesmumps_pgi.a",
        "#{cray_tpsl_dir}/lib/libzmumps_pgi.a",
        "#{cray_tpsl_dir}/lib/libmumps_common_pgi.a"
      ]

      mumps_options = "'--with-mumps-include=#{cray_tpsl_dir}/include', '--with-mumps-lib=#{mumps_libs.join(', ')}',"
      # PTHREAD_OPTIONS="'--with-pthread-lib=-lpthread',"
    end

    petsc_configure = "config/petsc-configure.py"

    debug = prefix.include?("debug") ? 1 : 0

    if build_name.include?("complex")
      scalar           = "complex"
      hypre_options    = ""
      spai_options     = ""
      ml_options       = ""
      sundials_options = ""
    else
      scalar        = "real"
      hypre_options = "'--download-hypre',"
      spai_options  = "'--download-spai',"
      ml_options    = "'--download-ml',"
    end

    spooles_options  = "'--download-spooles',"
    superlu_options  = "'--download-superlu', '--download-superlu_dist',"
    plapack_options  = "'--download-plapack',"
    triangle_options = "'--download-triangle',"

    if build_name.include?("64indices")
      index_options    = "'--with-64-bit-indices',"
      sundials_options = ""
      spooles_options  = ""
      spai_options     = ""
      pthread_options  = ""
      ml_options       = ""
      superlu_options  = ""
      plapack_options  = ""
      mumps_options    = ""
      mumps_libs       = ""
      triangle_options = ""
    end

    File.open(petsc_configure, "w+") do |f|
      f.write <<-EOF.strip_heredoc
        #!/usr/bin/env python
        configure_options = [
          '--prefix=#{prefix}',
          #'--PETSC_ARCH=xk-debug',
          '--with-debugging=#{debug}',
          '--with-scalar-type=#{scalar}',
          #{index_options}
          #'--COPTFLAGS=-fast -mp',
          #'--CXXOPTFLAGS=-fast -mp',
          #'--FOPTFLAGS=-fast -mp',
          '--with-blas-lapack-lib=#{blaslapack}',
          '--with-ldflags=-lacml -lacml_mv -lacml_cw',
          #'--with-blas-lapack-lib=-lacml -lacml_mv -lacml_cw',
          #'--with-mpiexec=/bin/false',
          '--with-x=0',
          '--download-umfpack',
          #{plapack_options}
          #{spai_options}
          #{spooles_options}
          #{ml_options}
          '--download-blacs',
          #{hypre_options}
          #{mumps_options}
          '--download-metis=1',
          '--download-parmetis',
          '--download-scalapack',
          #{superlu_options}
          '--download-pastil',
          '--download-ptscotch',
          '--download-pastix',
          #{triangle_options}
          #{sundials_options}
          '--known-level1-dcache-size=16384',
          '--known-level1-dcache-linesize=64',
          '--known-level1-dcache-assoc=4',
          '--known-memcmp-ok=1',
          '--known-sizeof-char=1',
          '--known-sizeof-void-p=8',
          '--known-sizeof-short=2',
          '--known-sizeof-int=4',
          '--known-sizeof-long=8',
          '--known-sizeof-long-long=8',
          '--known-sizeof-float=4',
          '--known-sizeof-double=8',
          '--known-sizeof-size_t=8',
          '--known-bits-per-byte=8',
          '--known-sizeof-MPI_Comm=4',
          '--known-sizeof-MPI_Fint=4',
          '--known-mpi-long-double=0',
          '--known-mpi-c-double-complex=0',
          '--with-cc=cc',
          '--with-cxx=CC',
          '--with-fc=ftn',
          '--with-mpi-dir=#{cray_mpich2_dir}',
          '--with-hdf5-dir=#{hdf5_dir}',
          #{pthread_options}
          '--with-batch=1',
          '--with-mpi-shared=0',
          '--with-shared-libraries=0',
          '--known-mpi-shared-libraries=0',
          '--with-clib-autodetect=0',
          '--with-fortranlib-autodetect=0',
          '--with-cxxlib-autodetect=0',
        ]
        if __name__ == '__main__':
          import os
          import sys
          sys.path.insert(0, os.path.abspath('config'))
          import configure
          configure.petsc_configure(configure_options)
      EOF
    end

    module_list
    system "cat #{petsc_configure}"
    system "chmod +x #{petsc_configure}"
    system "./#{petsc_configure}"
    system "make all"
    system "make install"
  end
end
