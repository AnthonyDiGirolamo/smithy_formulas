class GitFormula < Formula
  homepage "https://git-core.googlecode.com/"
  url "https://github.com/git/git/archive/v2.3.2.tar.gz"
  sha256 "7d8e15a2f41b8d6c391e527f461d61027cf3391c9ccc89b8c1a1a0785f18a0fb"
  depends_on ["curl/7.39.0","zlib"]

  def install
    module_list
    system "make configure"
    system "./configure --prefix=#{prefix} --with-curl=#{curl.prefix} --with-zlib=#{zlib.prefix}"
    system "make install"

    system "mkdir -p #{prefix}/share/man"
    system "curl -O https://www.kernel.org/pub/software/scm/git/git-manpages-2.3.2.tar.gz"
    system "cd #{prefix}/share/man && tar xf #{prefix}/source/git-manpages-2.3.2.tar.gz"
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
    prepend-path PERL5LIB  $PREFIX/lib64/perl5/site_perl
    prepend-path MANPATH   $PREFIX/share/man
    setenv       GITDIR    $PREFIX
  MODULEFILE
end
