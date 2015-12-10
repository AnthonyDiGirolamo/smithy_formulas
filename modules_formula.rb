class ModulesFormula < Formula
  homepage "http://modules.sourceforge.net/"
  url "http://downloads.sourceforge.net/project/modules/Modules/modules-3.2.10/modules-3.2.10.tar.gz"

  def install
    module_list
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
