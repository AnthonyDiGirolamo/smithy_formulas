class HtcondorFormula < Formula
  homepage "http://research.cs.wisc.edu/htcondor"
  url "http://parrot.cs.wisc.edu//symlink/20150313031501/8/8.3/8.3.4/b40abf516487d322ce3eed4b23b555b9/condor_src-8.3.4-all-all.tar.gz"

  module_commands [ "load cmake automake autoconf libtool gcc/4.4.7 byacc flex python" ]

  def install
    module_list
    system './configure_uw \
-DLIBUUID_FOUND_SEARCH_uuid=/sw/redhat6/uuid/master.zip/rhel6.6_gnu4.4.7/lib/libuuid.a \
-DLDAP_FOUND_SEARCH_ldap=/sw/redhat6/openldap/2.4.40/rhel6.6_gnu4.4.7/lib/libldap.a \
-DHAVE_LDAP_H=/sw/redhat6/openldap/2.4.40/rhel6.6_gnu4.4.7/include/ldap.h \
-DEXPAT_FOUND_SEARCH_expat=/sw/redhat6/expat/2.1.0/rhel6.6_gnu4.4.7/lib/libexpat.a \
-DBISON=/sw/redhat6/bison/1.25/rhel6.6_gnu4.4.7/bin/bison \
-DFLEX=/sw/redhat6/flex/2.5.39/rhel6.6_gnu4.4.7/bin/flex \
-DHAVE_LIBCARES_SEARCH_cares=/sw/redhat6/libcares/1.10.0/rhel6.6_gnu4.4.7/lib/libcares.a \
-DHAVE_LIBPAM_SEARCH_pam=/lib64/libpam.so.0 \
-DCURL_FOUND=/autofs/na4_sw/redhat6/curl/7.39.0/rhel6.6_gnu4.4.7/source/lib/libcurl.la \
-DLIBXML2_FOUND=/sw/redhat6/libxml2/2.9.1/rhel6_gnu4.7.1/libxml2-2.9.1/libxml2.la \
-DHAVE_BACKFILL:BOOL=FALSE \
-DHAVE_BOINC:BOOL=FALSE \
-DWITH_GSOAP:BOOL=FALSE \
-DWITH_POSTGRESQL:BOOL=FALSE \
-DWANT_LEASE_MANAGER:BOOL=FALSE \
-DWANT_FULL_DEPLOYMENT:BOOL=FALSE \
-DWANT_GLEXEC:BOOL=FALSE \
-D_VERBOSE:BOOL=TRUE \
-DWITH_BLAHP:BOOL=FALSE \
-DWITH_CREAM:BOOL=OFF \
-DWITH_UNICOREGAHP:BOOL=OFF \
-DWITH_BOSCO:BOOL=OFF \
-DWITH_GLOBUS:BOOL=FALSE \
-DWITH_VOMS:BOOL=FALSE \
-DCLIPPED:BOOL=ON \
-DWITH_LIBVIRT:BOOL=OFF \
-DWITH_LIBDELTACLOUD:BOOL=OFF \
-DPCRE_INSTALL_LOC=/sw/redhat6/pcre/8.32/rhel6.6_gnu4.4.7'
  end

  modulefile <<-modulefile.strip_heredoc
    #%Module
    proc moduleshelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # one line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
  modulefile
end
