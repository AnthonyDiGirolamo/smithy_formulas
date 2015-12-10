class BbcpFormula < Formula
  homepage "https://www.slac.stanford.edu/~abh/bbcp/"
  url "http://www.slac.stanford.edu/~abh/bbcp/bin/amd64_rhel60/bbcp"
  sha1 "961efca750ea3dc593fdfba59c786adacbd33f46"

  def install
    system "wget http://www.slac.stanford.edu/~abh/bbcp/bin/amd64_rhel60/bbcp"
    system "mkdir ../bin"
    system "mv bbcp ../bin"
    system "chmod +x ../bin/bbcp"
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
  MODULEFILE
end
