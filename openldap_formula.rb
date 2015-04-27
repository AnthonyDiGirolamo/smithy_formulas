class OpenldapFormula < Formula
  homepage "http://www.openldap.org/software/download/"
  url "ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.40.tgz"

  def install
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
  #%Module
  prepend-path PKG_CONFIG_PATH fixme
  MODULEFILE
end
