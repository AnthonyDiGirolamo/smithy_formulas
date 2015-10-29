class GoFormula < Formula
  homepage "https://golang.org"
  url "https://storage.googleapis.com/golang/go1.5.1.linux-amd64.tar.gz"
  sha1 "46eecd290d8803887dec718c691cc243f2175fe0"

  module_commands ["unload PrgEnv-pgi PrgEnv-intel PrgEnv-gnu PE-pgi PE-intel PE-gnu"]

  def install
    # It's a binary, so just chill
    system("mv * ../")
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
    setenv       GOROOT    $PREFIX
    setenv       GOPATH    $::env(HOME)/.go
  MODULEFILE
end
