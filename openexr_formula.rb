class OpenexrFormula < Formula
  homepage "http://www.openexr.org/"
  url "http://download.savannah.nongnu.org/releases/openexr/openexr-2.2.0.tar.gz"
  modules do
    case build_name
    when /gnu/   then ["gcc", "ilmbase"]
    end
  end

  def install
    module_list
    case build_name
    when /gnu/
      cc = "gcc"
    end
    system "cmake -DILMBASE_PACKAGE_PREFIX=$ILM_PREFIX -DCMAKE_INSTALL_PREFIX=#{prefix}; make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
      puts stderr "<%= @package.name %> <%= @package.version %>"
      puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"
    set PREFIX <%= @package.prefix %>
    setenv EXR_PATH $PREFIX
    prepend-path PATH      $PREFIX/bin
    prepend-path MANPATH   $PREFIX/share/man
    MODULEFILE
end
