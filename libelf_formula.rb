class LibelfFormula < Formula
  homepage "http://www.mr511.de/software/english.html"
  url "http://www.mr511.de/software/libelf-0.8.13.tar.gz"
  version "0.8.13"

  module_commands = [ "purge" ]

  def install
    module_list
    ENV['CC'] = "gcc"
    ENV['CXX'] = "g++"
    system "./configure --prefix=#{prefix} --enable-debug"
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

    # Helpful ENV Vars
    setenv LIBELF_DIR $PREFIX
    setenv LIBELF_LIB "-L$PREFIX/lib"
    setenv LIBELF_INC "-I$PREFIX/include"

    # Common Paths
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
  MODULEFILE
end
