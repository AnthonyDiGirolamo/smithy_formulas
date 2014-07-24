class PapiFormula < Formula
  homepage 'http://icl.cs.utk.edu/papi/index.html'
  url 'http://icl.cs.utk.edu/projects/papi/downloads/papi-5.3.2.tar.gz'

  module_commands [ "purge", "switch PE-intel PE-gnu" ]

  def install
    module_list
    Dir.chdir prefix+"/source/src"
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
