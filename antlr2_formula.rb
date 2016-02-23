class Antlr2Formula < Formula
  homepage "http://www.antlr2.org/"
  url "http://www.antlr2.org/download/antlr-2.7.7.tar.gz"

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")
    [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel",
      "load #{pe}gnu",
      "load java"
    ]
  end
  

  def install
    module_list

    patch <<-EOF.strip_heredoc
    --- ./lib/cpp/antlr/CharScanner.hpp       2006-11-01 21:37:17.000000000 +0000
    +++ ./lib/cpp/antlr/CharScanner.hpp       2013-05-03 18:56:47.938477000 +0000
    @@ -11,6 +11,8 @@
     #include <antlr/config.hpp>

     #include <map>
    +#include <cstdio>
    +#include <cstring>

     #ifdef HAS_NOT_CCTYPE_H
     #include <ctype.h>
    EOF

    system "./configure --prefix=#{prefix}"
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

    set PREFIX <%= @package.prefix %>

    prepend-path PATH      $PREFIX/bin
    prepend-path MANPATH   $PREFIX/share/man
  MODULEFILE

end
