class GitFormula < Formula
  homepage "https://git-core.googlecode.com/"
  url "https://git-core.googlecode.com/files/git-1.8.4.1.tar.gz"
  sha1 "49004a8dfcbb7c0848147737d9877fd7313a42ec"
  depends_on "curl"

  module_commands [ "purge" ]

  def install
    module_list
    system "./configure --prefix=#{prefix} --with-curl=#{curl.prefix}"
    system "make"
    system "make install"

    system "mkdir -p #{prefix}/share/man"
    system "curl -O https://git-core.googlecode.com/files/git-manpages-1.8.4.1.tar.gz" 
    system "cd #{prefix}/share/man && tar xf #{prefix}/source/git-manpages-1.8.4.1.tar.gz"

    system "wget http://search.cpan.org/CPAN/authors/id/S/SH/SHLOMIF/Error-0.17021.tar.gz"
    system "tar xf Error-0.17021.tar.gz"
    Dir.chdir prefix + "/source/Error-0.17021"
    system "perl Makefile.PL PREFIX=#{prefix}"
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
    prepend-path PERL5LIB  $PREFIX/lib64/perl5/site_perl
    prepend-path MANPATH   $PREFIX/share/man
    setenv       GITDIR    $PREFIX
  MODULEFILE
end
