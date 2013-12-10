class ValgrindFormula < Formula
  homepage "http://valgrind.org/"
  url "http://www.valgrind.org/downloads/valgrind-3.9.0.tar.bz2"
  md5 "0947de8112f946b9ce64764af7be6df2"

  module_commands [
    "unload PrgEnv-gnu PrgEnv-pgi PrgEnv-intel PrgEnv-cray"
  ]

  def install
    module_list
    system "./configure --prefix=#{prefix} --build=amd64-linux"
    system "make"
    system "make install"
  end

  modulefile <<-EOF.strip_heredoc
    #%Module
    proc ModulesHelp { } {
      puts stderr "<%= @package.name %> <%= @package.version %>"
      puts stderr "Sets up environment to use valgrind."
      puts stderr "Usage:   valgrind a.out"
      puts stderr " "
      puts stderr "Also sets VALGRIND_DIR to point to installation directory "
      puts stderr " "
      puts stderr "Note that this software is untested and may not work properly. "
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    <% if @builds.size > 1 %>
    <%= module_build_list @package, @builds %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    <% else %>
    set PREFIX <%= @package.prefix %>
    <% end %>

    setenv VALGRIND_DIR $PREFIX

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LIBRARY_PATH    $PREFIX/lib
    prepend-path INCLUDE_PATH    $PREFIX/include
    prepend-path MANPATH         $PREFIX/man
    prepend-path VALGRIND_LIB    $PREFIX/lib/valgrind
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
  EOF
end
