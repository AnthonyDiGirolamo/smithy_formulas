class AutomakeFormula < Formula
  homepage "http://www.gnu.org/software/automake/"
  url "http://ftp.gnu.org/gnu/automake/automake-1.14.tar.gz"

  module_commands [ "load autoconf" ]

  def install
    module_list
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"
  end

  modulefile <<-modulefile.strip_heredoc
    #%module
    proc moduleshelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # one line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    module load autoconf
    prereq autoconf

    set prefix <%= @package.prefix %>

    prepend-path path            $prefix/bin
    prepend-path ld_library_path $prefix/lib
    prepend-path manpath         $prefix/share/man
    prepend-path pkg_config_path $prefix/lib/pkgconfig
  modulefile
end
