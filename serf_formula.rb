class SerfFormula < Formula
  homepage "https://code.google.com/p/serf/"
  url "https://archive.apache.org/dist/serf/serf-1.3.8.tar.bz2"
  sha1 "1d45425ca324336ce2f4ae7d7b4cfbc5567c5446"
  depends_on ["scons","apr","apr-util","expat"]
  module_commands ["purge","load python","load scons"]

  def install
    module_list
    system "scons APR=#{apr.prefix} APU=#{apr_util.prefix} OPENSSL=/usr PREFIX=#{prefix} LINKFLAGS=-L#{expat.prefix}/lib CPPFLAGS=-I#{expat.prefix}/include"
#    system "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:#{apr_util.prefix}/lib:#{apr.prefix}/lib scons check"
    system "scons install"
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
    prepend-path MANPATH   $PREFIX/share/man
  MODULEFILE
end
