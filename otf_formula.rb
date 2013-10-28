class OtfFormula < Formula
  homepage "http://www.tu-dresden.de/die_tu_dresden/zentrale_einrichtungen/zih/forschung/projekte/otf"
  url "http://wwwpub.zih.tu-dresden.de/~mlieber/dcount/dcount.php?package=otf&get=OTF-1.12.4salmon.tar.gz"
  version "1.12.4salmon"

  module_commands [
    "unload PrgEnv-gnu PrgEnv-pgi PrgEnv-intel PrgEnv-cray PrgEnv-pathscale",
    "load PrgEnv-gnu"
  ]

  def install
    module_list
    ENV["CC"] = "gcc"
    ENV["CXX"] = "g++"
    # On Cray systems, use compiler wrappers for MPI programs
    ENV["MPICC"] = "cc" if build_name =~ /cle([\d\.]+)/
    ENV["MPICXX"] = "CC" if build_name =~ /cle([\d\.]+)/
    system "./configure --prefix=#{prefix} --disable-shared"
    system "make"
    system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    <% if @builds.size > 1 %>
    <%= module_build_list @package, @builds %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    <% else %>
    set PREFIX <%= @package.prefix %>
    <% end %>

    setenv OTF_DIR $PREFIX
    setenv OTF_INC $PREFIX/include
    setenv OTF_LIB $PREFIX/lib

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LIBRARY_PATH    $PREFIX/lib
    prepend-path INCLUDE_PATH    $PREFIX/include
  MODULEFILE
end
