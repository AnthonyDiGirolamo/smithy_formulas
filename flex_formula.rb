class FlexFormula < Formula
  homepage "http://flex.sourceforge.net/"
  url      "http://iweb.dl.sourceforge.net/project/flex/flex-2.5.39.tar.xz"

  def install
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
  #%Module
  prepend-path PATH <%= @package.prefix %>
  MODULEFILE
end
