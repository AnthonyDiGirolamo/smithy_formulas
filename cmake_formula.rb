class CmakeFormula < Formula
  homepage "http://www.cmake.org/"
  url      "http://www.cmake.org/files/v2.8/cmake-2.8.11.2.tar.gz"

  module_commands [ "purge" ]

  def install
    module_list
    system "./bootstrap --prefix=#{prefix} --no-qt-gui"
    system "make all"
    system "make install"
  end
end
