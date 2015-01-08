class GitFormula < Formula
  homepage "https://git-core.googlecode.com/"
  url "https://www.kernel.org/pub/software/scm/git/git-2.2.0.tar.gz"
  sha256 "bea9548f5a39daaf7c3873b6a5be47d7f92cbf42d32957e1be955a2e0e7b83b4"
  depends_on "curl/7.39.0"
  module_commands [ "purge" ]

  def install
    module_list
    system "make configure"
    system "./configure --prefix=#{prefix} --with-curl=#{curl.prefix}"
    system "make install"

    system "mkdir -p #{prefix}/share/man"
    system "curl -O https://www.kernel.org/pub/software/scm/git/git-manpages-2.2.0.tar.gz"
    system "cd #{prefix}/share/man && tar xf #{prefix}/source/git-manpages-2.2.0.tar.gz"
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
