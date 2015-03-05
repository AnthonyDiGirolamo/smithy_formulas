class NcviewFormula < Formula
  homepage "http://meteora.ucsd.edu/~pierce/ncview_home_page.html"
  url "ftp://cirrus.ucsd.edu/pub/ncview/ncview-2.1.2.tar.gz"

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel",
      "load #{pe}gnu",
      "load cray-hdf5",
      "load cray-netcdf" ]
  end

  depends_on [ "udunits/*/*gnu*" ]

  def install
    # LDFLAGS="-L${NETCDF_LIB} -L${HDF5_LIB} -L${SW_BLDDIR}/lib "
    # CPPFLAGS="-I${NETCDF_INC} -I${SW_BLDDIR}/include "
    module_list
    system "CC=gcc CXX=g++",
      "NETCDF_INC=$NETCDF_DIR/include",
      "NETCDF_LIB=$NETCDF_DIR/lib",
      "HDF5_INC=$HDF5_DIR/include",
      "HDF5_LIB=$HDF5_DIR/lib",
      "./configure --prefix=#{prefix}",
      "--with-udunits2_incdir=#{udunits.prefix}/include",
      "--with-udunits2_libdir=#{udunits.prefix}/lib"
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

    set PREFIX <%= @package.prefix %>

    prepend-path PATH      $PREFIX/bin
    prepend-path MANPATH   $PREFIX/share/man
    MODULEFILE
  end
end
