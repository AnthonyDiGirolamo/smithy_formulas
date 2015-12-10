class GeosFormula < Formula
  homepage "http://trac.osgeo.org/geos/"
  url "http://download.osgeo.org/geos/geos-3.3.9.tar.bz2"
  md5 "4794c20f07721d5011c93efc6ccb8e4e"

  def install
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
