class IlmbaseFormula < Formula
  homepage "http://www.openexr.org/"
  url "http://download.savannah.nongnu.org/releases/openexr/ilmbase-2.2.0.tar.gz"
  modules do
    case build_name
    when /gnu/   then ["gcc"]
    end
  end

  def install
    module_list
    case build_name
    when /gnu/
      cc = "gcc"
    end
    system "cmake -DCMAKE_INSTALL_PREFIX=#{prefix}; make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
      puts stderr "<%= @package.name %> <%= @package.version %>"
      puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"
    set PREFIX <%= @package.prefix %>
    setenv ILM_PREFIX  $PREFIX
    prepend-path PATH      $PREFIX/bin
    prepend-path MANPATH   $PREFIX/share/man
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
    MODULEFILE
end
