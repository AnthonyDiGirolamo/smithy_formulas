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

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel",
      "load #{pe}gnu",
      "load netcdf",
      "load hdf5",
      "load gsl",
      "load udunits",
      "load java" ]
  end

  depends_on ["udunits", "gsl/*/*gnu*", "expat", "antlr2"]

  def install
    module_list
    ENV["CC"]      = "gcc"
    ENV["CXX"]     = "g++"

    # ENV["CPPFLAGS"] = "-I#{expat.prefix}/include -I#{gsl.prefix}/include"
    # ENV["LDFLAGS"] = [
    #   "-L#{expat.prefix}/lib",
    #   "-Wl,-rpath,#{expat.prefix}/lib",
    #   "-Wl,-rpath,/opt/gcc/4.7.0/snos/lib64",
    #   "-Wl,-rpath,/opt/cray/netcdf/4.2.0/gnu/47/lib",
    #   "-Wl,-rpath,#{udunits.prefix}/lib",
    #   "-Wl,-rpath,#{gsl.prefix}/lib"
    # ].join(" ")

    # cpp_flags = "-I#{expat.prefix}/include -I#{gsl.prefix}/include"
    # ld_flags  = "-L#{expat.prefix}/lib -L#{gsl.prefix}/lib"

    system "UDUNITS2_PATH=#{udunits.prefix}",
           # "CPPFLAGS='#{cpp_flags}'",
           # "LDFLAGS='#{ld_flags}'",
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
