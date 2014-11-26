class PioFormula < Formula
  homepage "http://www.cesm.ucar.edu/models/pio/"
  url "none"
  module_commands [
    "unload PrgEnv-pgi PrgEnv-cray PrgEnv-intel PrgEnv-gnu",
    "load PrgEnv-intel",
    "load cray-netcdf/4.3.1",
    "load cray-parallel-netcdf/1.3.1.1",
    "load cmake",
    "load subvesrion"
]
  def install
    module_list
    env_vars=["MPICC=cc","CC=cc","MPIFC=ftn","FC=ftn","NETCDF_PATH=$NETCDF_DIR","PNETCDF_PATH=$PARALLEL_NETCDF_DIR"].join " "
    system "svn export http://parallelio.googlecode.com/svn/trunk_tags/pio1_7_1 source" unless Dir.exists?("source")
    system "#{env_vars} #{prefix}/source/pio/configure --prefix=#{prefix} --target=cray"
    system "#{env_vars} gmake install -C #{prefix}/source/pio/"
  end

  modulefile <<-MODULEFILE.strip_heredoc
#%Module
# parallel I/O library, compatible w netcdf

proc ModulesHelp { } {
puts stderr "<%= @package.name %> <%= @package.version %>"
puts stderr ""
puts stderr "Sets up environment to use pio 1.7.1 "
puts stderr "Usage:   cc test.c \${pio_LIB}"
puts stderr "Usage:   ftn test.f90 \${pio_LIB}"
 }
module-whatis "<%= @package.name %> <%= @package.version %>"

<% if @builds.size > 1 %>
<%= module_build_list @package, @builds %>

set PREFIX <%= @package.version_directory %>/$BUILD
<% else %>
set PREFIX <%= @package.prefix %>
<% end %>


setenv PIO_DIR $PREFIX
set PIO_INCLUDE_PATH " -I$PREFIX/include"
set PIO_LD_OPTS "-L$PREFIX/lib -lpio "
setenv PIO_LIB " $PIO_INCLUDE_PATH $PIO_LD_OPTS"

prepend-path PATH            $PREFIX/bin
prepend-path INCLUDE_PATH    $PREFIX/include
prepend-path LD_LIBRARY_PATH $PREFIX/lib
prepend-path MANPATH         $PREFIX/man
MODULEFILE
end
