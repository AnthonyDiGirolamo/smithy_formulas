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

  modulefile <<-MODULEFILE.strip_heredoc
	#%Module
	set vers   5.2.5
	set PREFIX /sw/xe6/globus/5.2.5/sles11.1_gnu4.3.4

	proc ModulesHelp { } {
	  puts stderr "Sets up environment to use Globus $vers"
	}
	module-whatis "globus 5.2.5"

	set x509_user_proxy $env(HOME)/.x509_user_proxy


	if { [info exists env(X509_USER_PROXY)] && ! [regexp {.x509_user_proxy} $env(X509_USER_PROXY)] } {
	  if {[file exists $x509_user_proxy]} {
	    set OLDPROXYDATE [exec openssl x509 -in $x509_user_proxy -enddate -noout ]
	    set NEWPROXYDATE [exec openssl x509 -in $env(X509_USER_PROXY) -enddate -noout ]
	    if {[string compare $NEWPROXYDATE $OLDPROXYDATE]} {
	      file copy -force $env(X509_USER_PROXY) $x509_user_proxy
	    }
	  } else {
	    file copy -force $env(X509_USER_PROXY) $x509_user_proxy
	  }
	}


	#setenv      MYPROXY_SERVER        myproxy1.princeton.rdhpcs.noaa.gov
	#setenv      MYPROXY_SERVER_DN     "/DC=gov/DC=noaa/DC=rdhpcs/OU=Certificate Authorities/CN=host/myproxy1.princeton.rdhpcs.noaa.gov"
	setenv       X509_CERT_DIR         /etc/grid-security/certificates
	setenv       X509_USER_PROXY       $x509_user_proxy
	prepend-path PATH                  $PREFIX/bin:$PREFIX/sbin
	prepend-path MANPATH               $PREFIX/man
	setenv       GLOBUS_LOCATION       $PREFIX
	setenv       GLOBUS_PATH           $PREFIX
	prepend-path LD_LIBRARY_PATH       $PREFIX/lib64
	prepend-path DYLD_LIBRARY_PATH     $PREFIX/lib64
	setenv       LIBPATH               $PREFIX/lib64
	setenv       SHLIB_PATH            $PREFIX/lib64
	setenv       GLOBUS_TCP_PORT_RANGE "40000,46999"
  MODULEFILE

end
