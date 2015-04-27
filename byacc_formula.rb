class ByaccFormula < Formula
  homepage "http://invisible-island.net/byacc"
  url      "http://invisible-island.net/datafiles/release/byacc.tar.gz"

  def install
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
  #%Module
  prepend-path PATH <%= @package.prefix %>/bin
  MODULEFILE
end
