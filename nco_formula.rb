class NcoFormula < Formula
  homepage "http://nco.sourceforge.net/"

  concern for_version "4.0.8" do
    included do
      url "http://nco.sourceforge.net/src/nco-4.0.8.tar.gz"
      md5 "edd1e5dab719b4bfc2cd07ec840f4f1d"
    end
  end

  concern for_version "4.3.9" do
    included do
      url "http://nco.sourceforge.net/src/nco-4.3.9.tar.gz"
      md5 "8f50e8b3fcec77e568d48ba452b69c47"
    end
  end

  concern for_version "4.5.2" do
    included do
      url "http://nco.sourceforge.net/src/nco-4.5.2.tar.gz"
      md5 "b2be3d112da617cd2eeec232e055b86b"
    end
  end

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")
    prfx = module_is_available?("PrgEnv-gnu") ? "cray-" : ""
    netcdf_module = module_is_available?("cray-netcdf") ? "cray-netcdf" : "netcdf"
    hdf5_module = module_is_available?("cray-hdf5") ? "cray-hdf5" : "hdf5"

    [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel",
      "load #{pe}gnu",
      "load #{netcdf_module}",
      "load #{hdf5_module}",
      "load gsl",
      "load udunits",
      "load java" ]
  end

  depends_on ["udunits", "gsl/*/*gnu*", "expat", "antlr2"]

  def install
    module_list
    ENV["CC"]      = "gcc"
    ENV["CXX"]     = "g++"

    system "UDUNITS2_PATH=#{udunits.prefix}",
           "HDF5_ROOT=$HDF5_DIR",
           "NETCDF4_ROOT=$NETCDF_DIR",
           "NETCDF_INC=$NETCDF_DIR/include",
           "NETCDF_LIB=$NETCDF_DIR/lib",
           "ANTLR_ROOT=#{antlr2.prefix}",
           "./configure --prefix=#{prefix}",
           "--disable-shared",
           "--enable-netcdf4",
           "--disable-udunits",
           "--enable-udunits2"

    system %q{for file in `grep -rl "\-L\-I\/" *` ; do sed -i 's/\-L\-I\//-I\//g' $file ; done}
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
