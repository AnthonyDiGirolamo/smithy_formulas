class SubversionFormula < Formula
  homepage "http://subversion.apache.org/"
  url "http://mirror.cogentco.com/pub/apache/subversion/subversion-1.8.3.tar.bz2"
  sha1 "e328e9f1c57f7c78bea4c3af869ec5d4503580cf"

  module_commands ["purge"]

  depends_on ["serf", "apr", "apr-util", "sqlite", "expat"]

  def install
    module_list
    ENV["CPPFLAGS"] = "-I#{expat.prefix}/include"
    ENV["LDFLAGS"] = "-L#{expat.prefix}/lib"
    system "./configure",
      "--prefix=#{prefix}",
      "--without-apxs",
      "--with-openssl",
      "--with-zlib=/usr",
      "--with-sqlite",
      "--with-serf=#{serf.prefix}",
      "--with-apr=#{apr.prefix}",
      "--with-apr-util=#{apr_util.prefix}",
      "--with-sqlite=#{sqlite.prefix}"

    system "make"
    system "make install"
  end

  modulefile do
    <<-MODULEFILE.strip_heredoc
      #%Module
      proc ModulesHelp { } {
         puts stderr "<%= @package.name %> <%= @package.version %>"
         puts stderr ""
      }
      module-whatis "<%= @package.name %> <%= @package.version %>"

      set PREFIX <%= @package.prefix %>

      prepend-path PATH            $PREFIX/bin
      prepend-path LD_LIBRARY_PATH $PREFIX/lib
      prepend-path LD_LIBRARY_PATH /sw/xk6/serf/1.3.2/sles11.1_gnu4.3.4/lib
      prepend-path MANPATH         $PREFIX/share/man
    MODULEFILE
  end
end
