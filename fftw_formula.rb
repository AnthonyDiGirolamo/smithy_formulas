class FftwFormula < Formula
  homepage "http://www.fftw.org/index.html"
  url "http://www.fftw.org/fftw-3.3.3.tar.gz"
  md5 "0a05ca9c7b3bfddc8278e7c40791a1c2"

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

    commands
  end

  def install
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

    enable_mpi = (name =~ /mpi/)

    module_list
    system "./configure --prefix=#{prefix} --enable-fortran #{enable_mpi ? "--enable-mpi" : ""}"
    system "make"
    system "make check" unless enable_mpi
    system "make install"
  end

  modulefile do
  <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr "Usage:   ftn test.f90   OR   pgf90/ifort/gfortran test.f90  \${FFTW3_LIB}"
       puts stderr "    or   cc test.c      OR   pgcc/icc/gcc test.c \${FFTW3_LIB}"
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"
    conflict fftw

    <% if @builds.size > 1 %>
    <%= module_build_list @package, @builds, :prgenv_prefix => #{module_is_available?("PrgEnv-gnu") ? '"PrgEnv-"' : '"PE-"'} %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    <% else %>
    set PREFIX <%= @package.prefix %>
    <% end %>

    set FFTW3_INCLUDE_PATH "-I$PREFIX/include"
    setenv FFTW3_LIB "$FFTW3_INCLUDE_PATH $FFTW3_LD_OPTS"

    # Use Cray magic to link against automagically
    prepend-path PE_PRODUCT_LIST "FFTW3"
    setenv FFTW3_INCLUDE_OPTS "-I$PREFIX/include"

    <% if (@package.name =~ /mpi/) %>
    set FFTW3_LD_OPTS "-L$PREFIX/lib -lfftw3_mpi -lfftw3f_mpi"
    setenv FFTW3_POST_LINK_OPTS "-L$PREFIX/lib -lfftw3_mpi -lfftw3f_mpi"
    <% else %>
    set FFTW3_LD_OPTS "-L$PREFIX/lib -lfftw3 -lfftw3f"
    setenv FFTW3_POST_LINK_OPTS "-L$PREFIX/lib -lfftw3 -lfftw3f"
    <% end %>


  MODULEFILE
  end
end
