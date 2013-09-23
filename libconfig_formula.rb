class LibconfigFormula < Formula
  homepage "http://www.hyperrealm.com/libconfig/"
  url "http://www.hyperrealm.com/libconfig/libconfig-1.4.9.tar.gz"

  module_commands [ "purge" ]

  def install
    module_list
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"
  end

  modulefile <<-EOF.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
    prepend-path INFOPATH        $PREFIX/share/info

    # Use Cray to link against automagically
    prepend-path PE_PRODUCT_LIST          "LIBCONFIG"
    setenv       LIBCONFIG_INCLUDE_OPTS   "-I$PREFIX/include"
    setenv       LIBCONFIG_POST_LINK_OPTS "-L$PREFIX/lib -lconfig -lconfig++"
  EOF
end
