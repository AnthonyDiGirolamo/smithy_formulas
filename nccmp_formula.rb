class NccmpFormula < Formula
  homepage "http://downloads.sourceforge.net/"
  url "http://downloads.sourceforge.net/project/nccmp/nccmp-1.8.0.0.tar.gz"
  sha256 "dd64bb0d66a1c3f358308b0d10e2881605b3391df285e3322cca0e578c8e2129"

  supported_build_names /(cray-)?netcdf.*/

  params netcdf_module_name: cray_system? ? "cray-netcdf" : "netcdf"
  params pe: cray_system? ? "PrgEnv-" : "PE-"

  module_commands do
    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel #{netcdf_module_name}" ]
    commands << "load #{pe}gnu"
    commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
    commands << "load #{netcdf_module_name}"
  end

  def install
    module_list

    netcdf_prefix = module_environment_variable(netcdf_module_name, "NETCDF_DIR")
    system "./configure CFLAGS=-I#{netcdf_prefix}/include LDFLAGS=-L#{netcdf_prefix}/lib --prefix=#{prefix}"
    system "make"
    system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    prepend-path PATH      $PREFIX/bin
  MODULEFILE
end
