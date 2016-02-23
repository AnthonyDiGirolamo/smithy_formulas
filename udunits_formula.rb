class UdunitsFormula < Formula
  homepage "http://www.unidata.ucar.edu/software/udunits/"
  url "ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-2.2.20.tar.gz"

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
    end
    commands
  end

  def install
    module_list

    case build_name
    when /gnu/
      ENV["CC"]  = "gcc"
      ENV["CXX"] = "g++"
      ENV["F77"] = "gfortran"
      ENV["FC"]  = "gfortran"
      ENV["F9X"] = "gfortran"
    when /pgi/
      ENV["CC"]  = "pgcc"
      ENV["CXX"] = "pgCC"
      ENV["F77"] = "pgf77"
      ENV["FC"]  = "pgf90"
      ENV["F9X"]  = "pgf90"
    when /intel/
      ENV["CC"]  = "icc"
      ENV["CXX"] = "icpc"
      ENV["F77"] = "ifort"
      ENV["FC"]  = "ifort"
      ENV["F9X"]  = "ifort"
    end

    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"
  end

  modulefile do
    <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    <% if @builds.size > 1 %>
    <%= module_build_list @package, @builds, :prgenv_prefix => #{module_is_available?("PrgEnv-gnu") ? '"PrgEnv-"' : '"PE-"'} %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    <% else %>
    set PREFIX <%= @package.prefix %>
    <% end %>

    set UDUNITS_INCLUDE_PATH "-I$PREFIX/include"
    set UDUNITS_LD_OPTS "-L$PREFIX/lib -ludunits2"

    setenv UDUNITS_DIR $PREFIX
    setenv UDUNITS_LIB "$UDUNITS_INCLUDE_PATH $UDUNITS_LD_OPTS"

    # Use Cray magic to link against automagically
    prepend-path PE_PRODUCT_LIST  "UDUNITS"
    setenv UDUNUTS_INCLUDE_OPTS   "$UDUNITS_INCLUDE_PATH"
    setenv UDUNUTS_POST_LINK_OPTS "$UDUNITS_LD_OPTS"

    prepend-path PATH             $PREFIX/bin
    prepend-path LIBRARY_PATH     $PREFIX/lib
    prepend-path INCLUDE_PATH     $PREFIX/include
    prepend-path INFOPATH         $PREFIX/share/info
    MODULEFILE
  end
end
