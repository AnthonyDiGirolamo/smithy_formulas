class GlobusFormula < Formula
  homepage "http://www.globus.org/toolkit/"
  url "http://toolkit.globus.org/ftppub/gt5/5.2/5.2.5/installers/src/gt5.2.5-all-source-installer.tar.gz"
  md5 "10ecf1cdb3c4381cb4c1534f393d263f"
  module_commands ["purge"]

  def install
    module_list
    system "./configure --prefix=#{prefix} --with-gsiopensshargs=--with-pam"
    system "make"
    system "make globus_ftp_client_test-compile"
    system "make install"
    system "cd ./source-trees/gridftp/client/test/ && cp -v globus-ftp-client-cksm-test globus-ftp-client-mlst-test globus-ftp-client-modification-time-test globus-ftp-client-size-test globus-ftp-client-delete-test #{prefix}/bin/"
  end
end
