class UberftpFormula < Formula
  homepage "https://github.com/JasonAlt/UberFTP"
  url "https://github.com/JasonAlt/UberFTP/archive/Version_2_7.tar.gz"

  version "2.7"

  module_commands do
    [ "load globus" ]
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

    prereq globus/5.2.1
    set PREFIX <%= @package.prefix %>

    prepend-path PATH      $PREFIX/bin
    prepend-path MANPATH   $PREFIX/man
  MODULEFILE
end
