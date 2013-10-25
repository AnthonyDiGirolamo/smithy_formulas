class SerfFormula < Formula
  homepage "https://code.google.com/p/serf/"
  url "https://serf.googlecode.com/files/serf-1.3.2.tar.bz2"
  sha1 "90478cd60d4349c07326cb9c5b720438cf9a1b5d"
  depends_on ["scons","apr","apr-util","expat"]
  module_commands ["purge","load scons"]

  def install
    module_list
    system "scons APR=#{apr.prefix} APU=#{apr_util.prefix} OPENSSL=/usr PREFIX=#{prefix} LINKFLAGS=-L#{expat.prefix}/lib CPPFLAGS=-I#{expat.prefix}/include"
#    system "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:#{apr_util.prefix}/lib:#{apr.prefix}/lib scons check"
    system "scons install"
  end
end
