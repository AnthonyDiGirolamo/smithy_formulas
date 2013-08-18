class GnuplotFormula < Formula
  homepage 'http://www.gnuplot.info'
  url 'http://downloads.sourceforge.net/project/gnuplot/gnuplot/4.6.3/gnuplot-4.6.3.tar.gz'
  sha256 'df5ffafa25fb32b3ecc0206a520f6bca8680e6dcc961efd30df34c0a1b7ea7f5'

  module_commands [ "purge", "load lua" ]

  depends_on "lua"

  def install
    module_list

    ENV["CPPFLAGS"] = "-I#{lua.prefix}/include"
    ENV["LDFLAGS"] = "-L#{lua.prefix}/lib"

    system "./configure --prefix=#{prefix}"
    system "make"
    system "make check"
    system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    module load lua
    prereq lua

    prepend-path PATH      $PREFIX/bin
    prepend-path MANPATH   $PREFIX/share/man
  MODULEFILE
end
