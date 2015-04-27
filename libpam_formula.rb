class LibpamFormula < Formula
  homepage "http://www.linux-pam.org"
  url      "http://www.linux-pam.org/library/Linux-PAM-1.1.5.tar.gz"

  def install
    system "./configure --prefix=#{prefix} --with-flex=/sw/redhat6/flex/2.5.39/rhel6.6_gnu4.4.7/"
    system "make"
    system "make install"
  end
end
