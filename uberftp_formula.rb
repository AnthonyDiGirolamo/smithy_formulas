class UberftpFormula < Formula
  homepage "https://github.com/JasonAlt/UberFTP"
  url "https://github.com/JasonAlt/UberFTP/archive/Version_2_8.tar.gz"
  md5 "bc7a159955a9c4b9f5f42f3d2b8fc830"

  version "2.8"

  module_commands do
    [ "load globus/5.2.5" ]
  end

  def install
    module_list
    globus_prefix = module_environment_variable("globus", "GLOBUS_LOCATION")

    ENV['CFLAGS'] = "-I#{globus_prefix}/include/globus/gcc64dbg -I#{globus_prefix}/include/globus"
    ENV['CPPFLAGS'] = "-I#{globus_prefix}/include/globus/gcc64dbg -I#{globus_prefix}/include/globus"
    ENV['LDFLAGS'] = "-L#{globus_prefix}/lib64"

    system "./configure --prefix=#{prefix} --with-globus=#{globus_prefix} --with-globus-flavor=gcc64dbg"
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

    prereq globus/5.2.5
    set PREFIX <%= @package.prefix %>

    prepend-path PATH      $PREFIX/bin
    prepend-path MANPATH   $PREFIX/man
  MODULEFILE
end
