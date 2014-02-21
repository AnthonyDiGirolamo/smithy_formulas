class PetscFormula < Formula
  homepage "http://www.mcs.anl.gov/petsc/index.html"
  url "http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.4.3.tar.gz"

  # Supported builds:
  # petsc/3.4.2/gnu4.7.2
  # petsc/3.4.2/gnu4.7.2_64indices
  # petsc/3.4.2-debug/gnu4.7.2
  # petsc/3.4.2-debug/gnu4.7.2_64indices
  # petsc-complex/3.4.2/gnu4.7.2
  # petsc-complex/3.4.2/gnu4.7.2_64indices
  # petsc-complex/3.4.2-debug/gnu4.7.2
  # petsc-complex/3.4.2-debug/gnu4.7.2_64indices

  depends_on do
    packages = [ ]
    packages = [ "cblas/20110120/*acml*" ] #if module_is_available?("PrgEnv-gnu")
    packages
  end

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    case build_name
    when /gnu/
      commands << "load #{pe}gnu"
      commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
    when /pgi/
      commands << "load #{pe}pgi"
      commands << "swap pgi pgi/#{$1}" if build_name =~ /pgi([\d\.]+)/
    when /intel/
      commands << "load #{pe}intel"
      commands << "swap intel intel/#{$1}" if build_name =~ /intel([\d\.]+)/
    when /cray/
      commands << "load #{pe}cray"
      commands << "swap cce cce/#{$1}" if build_name =~ /cray([\d\.]+)/
    end

    commands << "unload acml"
    commands << "load acml"

    if pe == "PrgEnv-"
      commands << "unload cray-hdf5 hdf5 cray-tpsl"
      commands << "load cray-hdf5"
      commands << "load cray-tpsl"
    else
      commands << "unload hdf5 szip"
      commands << "load szip hdf5/1.8.11"
    end

    commands << "load cmake"
    commands
  end

  def install
    ENV['PETSC_DIR'] = prefix+"/source"

    cray_build = true if module_is_available?("PrgEnv-gnu")

    if cray_build
      compilers        = "'--with-cc=cc', '--with-cxx=CC', '--with-fc=ftn',"
      # TITAN compute node
      known_info       = """
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
        '--known-mpi-long-double=1',
        '--known-mpi-c-double-complex=1',
        '--known-mpi-int64_t=1',
      """
      sundials_prefix  = module_environment_variable("cray-tpsl",   "CRAY_TPSL_PREFIX_DIR")
      mpich2_prefix    = module_environment_variable("cray-mpich2", "CRAY_MPICH2_DIR")
      hdf5_prefix      = module_environment_variable("cray-hdf5",   "HDF5_DIR")
    else
      # compilers        = "'--with-cc=mpicc', '--with-cxx=mpiCC', '--with-fc=mpif90',"
      compilers        = ""
      # This is for RHEA
      known_info       = """
        '--known-level1-dcache-size=32768',
        '--known-level1-dcache-linesize=64',
        '--known-level1-dcache-assoc=8',
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
        '--known-sizeof-MPI_Comm=8',
        '--known-sizeof-MPI_Fint=4',
        '--known-mpi-long-double=1',
        '--known-mpi-c-double-complex=0',
      """
      sundials_prefix  = ""
      sundials_options = "'--download-sundials',"
      mpich2_prefix    = module_environment_variable("ompi", "OMPI_DIR")
      hdf5_prefix      = module_environment_variable("hdf5/1.8.11", "HDF5_DIR")
    end

    acml_prefix = module_environment_variable("acml", "ACML_DIR")
    FileUtils.mkdir_p "#{prefix}/lib"

    case build_name
    when /gnu/
      FileUtils.cp "#{cblas.prefix}/lib/libcblas.a", "#{prefix}/lib", verbose: true
      FileUtils.cp "#{acml_prefix}/gfortran64/lib/libacml.a",   "#{prefix}/lib", verbose: true
      FileUtils.cp "#{acml_prefix}/gfortran64/lib/libacml.so",  "#{prefix}/lib", verbose: true
      blaslapack = "#{acml_prefix}/gfortran64/lib/libacml.a"
      blaslapack += ",#{cblas.prefix}/lib/libcblas.a" unless cray_build
      blaslapack_options = """
          # '--with-blas-lapack-lib=#{blaslapack}',
          '--with-blas-lapack-dir=#{acml_prefix}/gfortran64',
          '--with-ldflags=-lacml -lacml_mv -lacml_cw -lcblas',
          # '--with-blas-lapack-lib=-lacml -lacml_mv -lacml_cw',
          """

      if sundials_prefix.present?
        sundials_libs = [
          "#{sundials_prefix}/lib/libsundials_cvode_gnu.a",
          "#{sundials_prefix}/lib/libsundials_cvodes_gnu.a",
          "#{sundials_prefix}/lib/libsundials_ida_gnu.a",
          "#{sundials_prefix}/lib/libsundials_idas_gnu.a",
          "#{sundials_prefix}/lib/libsundials_kinsol_gnu.a",
          "#{sundials_prefix}/lib/libsundials_nvecparallel_gnu.a",
          "#{sundials_prefix}/lib/libsundials_nvecserial_gnu.a"
        ]
        sundials_options = "'--with-sundials-include=#{sundials_prefix}/include', '--with-sundials-lib=#{sundials_libs.join(', ')}',"
      end

      mumps_options    = "'--download-mumps',"
      pthread_options  = "'--with-pthreadclasses', '--with-pthread-dir=/usr',"

    # when /pgi/
    #   blaslapack = "#{acml_prefix}/pgi64/lib/libacml.a"

    #   if sundials_prefix.present?
    #     sundials_libs = [
    #       "#{sundials_prefix}/lib/libsundials_cvode_pgi.a",
    #       "#{sundials_prefix}/lib/libsundials_cvodes_pgi.a",
    #       "#{sundials_prefix}/lib/libsundials_ida_pgi.a",
    #       "#{sundials_prefix}/lib/libsundials_idas_pgi.a",
    #       "#{sundials_prefix}/lib/libsundials_kinsol_pgi.a",
    #       "#{sundials_prefix}/lib/libsundials_nvecparallel_pgi.a",
    #       "#{sundials_prefix}/lib/libsundials_nvecserial_pgi.a"
    #     ]
    #     sundials_options = "'--with-sundials-include=#{sundials_prefix}/include', '--with-sundials-lib=#{sundials_libs.join(', ')}',"
    #   end

    #   mumps_libs = [
    #     "#{sundials_prefix}/lib/libcmumps_pgi.a",
    #     "#{sundials_prefix}/lib/libptesmumps_pgi.a",
    #     "#{sundials_prefix}/lib/libdmumps_pgi.a",
    #     "#{sundials_prefix}/lib/libsmumps_pgi.a",
    #     "#{sundials_prefix}/lib/libesmumps_pgi.a",
    #     "#{sundials_prefix}/lib/libzmumps_pgi.a",
    #     "#{sundials_prefix}/lib/libmumps_common_pgi.a"
    #   ]

    #   mumps_options = "'--with-mumps-include=#{sundials_prefix}/include', '--with-mumps-lib=#{mumps_libs.join(', ')}',"
    #   # PTHREAD_OPTIONS="'--with-pthread-lib=-lpthread',"
    end

    if cray_build
      mpi_options = """
        '--with-mpi-shared=0',
        '--with-shared-libraries=0',
        '--known-mpi-shared-libraries=0',
        '--with-clib-autodetect=0',
        '--with-fortranlib-autodetect=0',
        '--with-cxxlib-autodetect=0',
      """
    else
      mpi_options = """
        '--with-mpi-shared=1',
        '--with-shared-libraries=1',
        '--known-mpi-shared-libraries=1',
        '--with-clib-autodetect=1',
        '--with-fortranlib-autodetect=1',
        '--with-cxxlib-autodetect=1',
      """
    end

    petsc_configure = "config/petsc-configure.py"

    debug = prefix.include?("debug") ? 1 : 0

    if prefix.include?("complex")
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
          #'--PETSC_ARCH=#{build_name}',
          '--with-debugging=#{debug}',
          '--with-scalar-type=#{scalar}',
          #{index_options}
          #'--COPTFLAGS=-fast -mp',
          #'--CXXOPTFLAGS=-fast -mp',
          #'--FOPTFLAGS=-fast -mp',
          #{blaslapack_options}
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
          #{known_info}
          #{compilers}
          '--with-hdf5-dir=#{hdf5_prefix}',
          '--with-mpi=1',
          '--with-mpi-dir=#{mpich2_prefix}',
          #'--with-mpiexec=/bin/false',
          #{pthread_options}
          '--with-batch=1',
          #{mpi_options}
          'PETSC_ARCH=petsc-configure',
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

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
      puts stderr "<%= @package.name %> <%= @package.version %> provided by the OLCF"
      puts stderr ""
      puts stderr "This version of petsc was compiled with the configuration located in:"
      puts stderr "<%= @package.prefix %>/source/config/petsc-configure.py"
    }
    module-whatis "<%= @package.name %> <%= @package.version %> provided by the OLCF"

    set PREFIX <%= @package.prefix %>

    conflict petsc
    conflict petsc-complex
    conflict cray-petsc

    setenv PETSC_DIR $PREFIX

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
  MODULEFILE
end
