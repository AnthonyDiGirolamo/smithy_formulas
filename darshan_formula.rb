class DarshanFormula < Formula
  homepage "http://www.mcs.anl.gov/research/projects/darshan"

  concern for_version("2.3.1") do
    included do
      url "ftp://ftp.mcs.anl.gov/pub/darshan/releases/darshan-2.3.1.tar.gz"
    end
  end

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if cray_system?

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    commands << "load #{pe}gnu"
    commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
    commands
  end


  def install
    module_list
    Dir.chdir("#{prefix}/source/darshan-runtime")

    # First compile runtime
    if cray_system?
        system "./configure --with-mem-align=8 --prefix=#{prefix} --with-jobid-env=PBS_JOBID --disable-cuserid CC=cc --with-log-path-by-env=DARSHAN_LOGPATH"
    else
        system "./configure --with-mem-align=8 --prefix=#{prefix} --with-jobid-env=PBS_JOBID CC=mpicc --with-log-path-by-env=DARSHAN_LOGPATH"
    end
    system "make"
    system "make install"

    Dir.chdir("#{prefix}/bin")
    system "cp darshan-mk-log-dirs.pl darshan-mk-log-dirs.pl.orig"

    patch <<-EOF.strip_heredoc
      --- a/darshan-mk-log-dirs.pl
      +++ b/darshan-mk-log-dirs.pl
      @@ -10,7 +10,7 @@
       # LOGDIR/<year>/<month>/<day>/
      
       # use log dir specified at configure time
      -$LOGDIR = "";
      +$LOGDIR = $ENV{'DARSHAN_LOGPATH'};
      
      
       my $year = (localtime)[5] + 1900;
      EOF

    Dir.chdir("#{prefix}/source/darshan-util")
    # Then compile darshan utilities
    system "./configure --prefix=#{prefix}"
    system "make"
    system "make install"

  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
      puts stderr "<%= @package.name %> <%= @package.version %>"
      puts stderr ""
      puts stderr "Please set the DARSHAN_LOGPATH variable to an"
      puts stderr "existing directory in the Lustre spaces. The"
      puts stderr "darshan logs will be written in that directory."
      puts stderr "By default this variable is set to '.' (the current"
      puts stderr "working directory)."
      puts stderr ""
      puts stderr "For example:"
      puts stderr "  export DARSHAN_LOGPATH=\\$MEMBERWORK/myLogs (in bash)"
      puts stderr "  setenv DARSHAN_LOGPATH \\$MEMBERWORK/myLogs (in tcsh)"
      puts stderr ""
    }
    
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"
    
    set BUILD sles11.3_gnu4.8.2

    if {![info exists BUILD]} {
      puts stderr "[module-info name] is only available for the following environments:"
      puts stderr "sles11.3_gnu4.8.2"
      break
    }

    set PREFIX <%= @package.version_directory %>/$BUILD
    
    prepend-path PE_PKGCONFIG_LIBS darshan-runtime
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path PATH $PREFIX/bin
    setenv       DARSHAN_LOGPATH ./

    if { [ module-info mode load ] } {
        puts stderr "Please set DARSHAN_LOGPATH to an existing directory in one"
        puts stderr "of the Lustre workspaces (\\$MEMBERWORK, \\$PROJWORK, \\$WORLDWORK)"
        puts stderr "For example:"
        puts stderr "  export DARSHAN_LOGPATH=\\$MEMBERWORK/<projID>/<username>/myLogs (in bash)"
        puts stderr "  setenv DARSHAN_LOGPATH \\$MEMBERWORK/<projID>/<username>/myLogs (in tcsh)"
        puts stderr ""
     }

  MODULEFILE
end
