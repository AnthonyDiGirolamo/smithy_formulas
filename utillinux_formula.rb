class UtillinuxFormula < Formula
  homepage "https://www.kernel.org/pub/linux/utils/util-linux"
  url "https://www.kernel.org/pub/linux/utils/util-linux/v2.26/util-linux-2.26.tar.gz"

  def install
    system "./configure --without-python --without-ncurses --prefix=#{prefix}"
    system "make"
    system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
  #%Module
  prepend-path PATH <%= @package.prefix %>/bin
  MODULEFILE
end
