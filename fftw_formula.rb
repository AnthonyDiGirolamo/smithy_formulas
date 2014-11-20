class FftwFormula < Formula
  homepage "http://www.fftw.org/index.html"
  #url "http://www.fftw.org/fftw-3.3.3.tar.gz"
  url "file:///sw/fftw/fftw/fftw-3.3.3.tar.gz"
  md5 "0a05ca9c7b3bfddc8278e7c40791a1c2"

  #module_commands do
  #  pe = "PE-"
  #  pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

  #  commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
  #  case build_name
  #  when /gnu/
  #    commands << "load #{pe}gnu"
  #    commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
  #  when /pgi/
  #    commands << "load #{pe}pgi"
  #    commands << "swap pgi pgi/#{$1}" if build_name =~ /pgi([\d\.]+)/
  #  when /intel/
  #    commands << "load #{pe}intel"
  #    commands << "swap intel intel/#{$1}" if build_name =~ /intel([\d\.]+)/
  #  when /cray/
  #    commands << "load #{pe}cray"
  #    commands << "swap cce cce/#{$1}" if build_name =~ /cray([\d\.]+)/
  #  end

  #  commands
  #end

  module_commands do
    commands = [ "purge" ]
    case build_name
    when /gnu/
     commands << "load gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
    when /pgi/
      commands << "load pgi/#{$1}" if build_name =~ /pgi([\d\.]+)/
    when /intel/
      commands << "load intel/#{$1}" if build_name =~ /intel([\d\.]+)/
    when /cray/
      commands << "load cce/#{$1}" if build_name =~ /cray([\d\.]+)/
    end
    commands << "load openmpi/1.8.2"
    commands
  end

  def install
    module_list
    if build_name =~ /gnu/
      ENV["CC"]  = "gcc"
      ENV["CXX"] = "g++"
      ENV["F77"] = "gfortran"
      ENV["FC"]  = "gfortran"
    elsif build_name =~ /intel/
      ENV["CC"]  = "icc"
      ENV["CXX"] = "icpc"
      ENV["F77"] = "ifort"
      ENV["FC"]  = "ifort"
    elsif build_name =~ /pgi/
      ENV["CC"]  = "pgcc"
      ENV["CXX"] = "pgCC"
      ENV["F77"] = "pgf77"
      ENV["FC"]  = "pgf90"
    end

    enable_parallel= (name =~ /parallel/) ? "--enable-openmp --enable-mpi --enable-threads" : ""

    module_list
    system "./configure --prefix=#{prefix} --enable-fortran #{enable_parallel}"
    system "make"
    system "make check" unless enable_parallel
    system "make install"
  end

  modulefile do
  <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr {
       <%= @package.name %> <%= @package.version %>
       Usage:   pgf90/ifort/gfortran test.f90  \${FFTW3_INCLUDE_OPTS} \${FFTW3_LD_OPTS_[SERIAL|MPI|OMP|THREADS]}
           or   pgcc/icc/gcc test.c \${FFTW3_INCLUDE_OPTS} \${FFTW3_LD_OPTS_[SERIAL|MPI|OMP|THREADS]}
       }
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"
    conflict fftw

    <% if @builds.size > 1 %>
    <%= module_build_list @package, @builds, :prgenv_prefix => #{module_is_available?("PrgEnv-gnu") ? '"PrgEnv-"' : '"PE-"'} %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    <% else %>
    set PREFIX <%= @package.prefix %>
    <% end %>

    prepend-path LD_LIBRARY_PATH $PREFIX/lib

    setenv FFTW3_DIR "$PREFX"
    setenv FFTW3_INCLUDE_OPTS "-I$PREFIX/include"
    setenv FFTW3_LD_OPTS_SERIAL "-L$PREFIX/lib -lfftw3"
    setenv FFTW3_LD_OPTS_MPI "-L$PREFIX/lib -lfftw3_mpi -lfftw3"
    setenv FFTW3_LD_OPTS_OMP "-L$PREFIX/lib -lfftw3_omp -lfftw3"
    setenv FFTW3_LD_OPTS_THREADS "-L$PREFIX/lib -lfftw3_threads -lfftw3"

    setenv FFTW3_INCLUDE_PATH "$PREFIX/include"
    setenv FFTW3_LIBRARY_PATH "$PREFIX/lib"

  MODULEFILE
  end
end
