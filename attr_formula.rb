class AttrFormula < Formula
  homepage "http://savannah.nongnu.org/projects/attr"
  url "http://download.savannah.gnu.org/releases/attr/attr-2.4.47.src.tar.gz"


  def install
    module_list
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install-dev"
  end

  modulefile <<-modulefile.strip_heredoc
    #%Module
    proc moduleshelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # one line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    module load libffi
    prereq libffi

    set PREFIX <%= @package.prefix %>

    prepend-path PATH            $PREFIX/bin
    prepend-path CPATH           $PREFIX/include
    prepend-path INCLUDE_PATH    $PREFIX/include
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
  modulefile
end
