class GitFormula < Formula
  homepage "https://git-core.googlecode.com/"
  url "https://www.kernel.org/pub/software/scm/git/git-1.8.5.5.tar.gz"
  sha1 "5b541e863389ae4fc20efd46c10334a5150cc423"
  depends_on "curl/7.30.0"
  module_commands [ "purge","load curl/7.30.0" ]

  def install
    module_list
    puts "test"
    system "./configure --prefix=#{prefix} --with-curl=#{curl.prefix}"
    system "make"
    system "make install"

    system "mkdir -p #{prefix}/share/man"
    system "wget https://git-core.googlecode.com/files/git-manpages-1.8.5.5.tar.gz" 
    system "cd #{prefix}/share/man && tar xf #{prefix}/source/git-manpages-1.8.5.5.tar.gz"
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
