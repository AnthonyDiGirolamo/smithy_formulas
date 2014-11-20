class DdtFormula < Formula
  homepage "http://www.allinea.com"
  url      "none"

  SourcesDir = "/sw/sources/ddt"
  AutoCopyDir = File.join(SourcesDir, "auto-copy")

  def install
    raise "You must specify a version" if version == "none"

    if build_name.include?("sles11")
      ddt_os = "Suse-11"
    elsif build_name.include?("centos5")
      ddt_os = "Redhat-5.7"
    elsif build_name.include?("centos6") || build_name.include?("rhel6")
      ddt_os = "Redhat-6.0"
    else
      raise "Unsupported build type (#{build_name})"
    end

    tarfile = "allinea-tools-#{version}-#{ddt_os}-x86_64.tar"
    system ["wget", "http://content.allinea.com/downloads/#{tarfile}"] unless File.exists?(tarfile)
    system "tar -xf #{tarfile}"
    FileUtils.rm tarfile
    temp_dir_name = tarfile.chomp(".tar")
    Dir.chdir temp_dir_name do |dirname|
      system "./textinstall.sh --accept-licence #{prefix}"
    end
    FileUtils.rm_rf temp_dir_name

    # Delete existing templates if we'll be copying our own
    if Dir.exist?(File.join(AutoCopyDir, Smithy::Config.arch, "templates"))
      FileUtils.rm_f(Dir.glob(File.join(prefix, "templates", "*"))) # Delete existing templates
    end

    # Copy sources/default and sources/arch to directory tree
    FileUtils.cp_r Dir.glob(File.join(AutoCopyDir, "default", "*")), prefix
    FileUtils.cp_r Dir.glob(File.join(AutoCopyDir, Smithy::Config.arch, "*")), prefix

    #case Smithy::Config.arch
    #when "xk6"
    #  FileUtils.cp File.join(SourcesDir, "titan.nodes"), prefix
    #  FileUtils.cp File.join(SourcesDir, "system.config.titan"), File.join(prefix, "system.config")
    #  FileUtils.cp File.join(SourcesDir, "remote-init.titan"), File.join(prefix, "remote-init")

    #  FileUtils.rm_f(Dir.glob(File.join(prefix, "templates", "*"))) # Delete existing templates
    #  FileUtils.cp File.join(SourcesDir, "titan.qtf"), File.join(prefix, "templates")
    #  FileUtils.cp File.join(SourcesDir, "titan-gpu.qtf"), File.join(prefix, "templates")
    #when "xc30"
    #  FileUtils.cp File.join(SourcesDir, "remote-init.eos"), File.join(prefix, "remote-init")
    #else
    #  FileUtils.cp File.join(SourcesDir, "remote-init.default"), File.join(prefix, "remote-init")
    #end
  end


  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
            puts stderr "Sets up the environment to use Allinea DDT <%= @package.version %>"
    }
    module-whatis "Sets up the environment to use Allinea DDT <%= @package.version %>"
    
    set ddt_version <%= @package.version %>
    set apppath <%= @package.prefix %>
    setenv DDT_HOME $apppath
    setenv DDT_LICENSE_FILE /sw/sources/ddt/Licence
    setenv MAP_LICENSE_FILE /sw/sources/ddt/Licence.map
    prepend-path PATH $apppath/bin

    <% if @package.build_name.include?("sles11") %>
    ## Special notice that memory debugging has changed
    if { [ module-info mode load ] } {
        puts stderr " "
        puts stderr "***NOTICE TO DDT USERS*** "
        puts stderr "With version 4.0 (and later) of DDT, the procedure for memory debugging has "
        puts stderr "changed.  You no longer need to compile with the ddtmem-cc, ddtmem-CC, "
        puts stderr "and ddtmem-ftn scripts.  Rather, just load the ddt-memdebug module (in "
        puts stderr "addition to this module) and compile as you normally would (with cc, "
        puts stderr "CC and/or ftn).  The appropriate memory debugging libraries will be "
        puts stderr "linked automatically. "
        puts stderr " "
        puts stderr "Please direct questions to help@olcf.ornl.gov "
        puts stderr " "
    }

    setenv DDTMPIRUN <%= Smithy::Config.arch == "xc30" ? "/opt/cray/alps/default/bin/aprun" : "/usr/bin/aprun" %>

    # Add memory debugging libraries to LD_LIBRARY_PATH on the compute nodes
    prepend-path LD_LIBRARY_PATH "/opt$apppath/lib/64"
    prepend-path LD_LIBRARY_PATH "/opt$apppath/lib/32"
    <% end %>

  MODULEFILE
end

##class DdtFormula < Formula
##  homepage "http://www.allinea.com"
##  url      "none"
##
##  SourcesDir = "/sw/sources/ddt"
##  AutoCopyDir = File.join(SourcesDir, "auto-copy")
##
##  def install
##    raise "You must specify a version" if version == "none"
##
##    if build_name.include?("sles11")
##      ddt_os = "Suse-11"
##    elsif build_name.include?("centos5")
##      ddt_os = "Redhat-5.7"
##    elsif build_name.include?("centos6") || build_name.include?("rhel6")
##      ddt_os = "Redhat-6.0"
##    else
##      raise "Unsupported build type (#{build_name})"
##    end
##
##    tarfile = "allinea-tools-#{version}-#{ddt_os}-x86_64.tar"
##    system ["wget", "http://content.allinea.com/downloads/#{tarfile}"] unless File.exists?(tarfile)
##    system "tar -xf #{tarfile}"
##    FileUtils.rm tarfile
##    temp_dir_name = tarfile.chomp(".tar")
##    Dir.chdir temp_dir_name do |dirname|
##      system "./textinstall.sh --accept-licence #{prefix}"
##    end
##    FileUtils.rm_rf temp_dir_name
##
##    # Delete existing templates if we'll be copying our own
##    if Dir.exist?(File.join(AutoCopyDir, Smithy::Config.arch, "templates"))
##      FileUtils.rm_f(Dir.glob(File.join(prefix, "templates", "*"))) # Delete existing templates
##    end
##
##    # Copy sources/default and sources/arch to directory tree
##    FileUtils.cp_r Dir.glob(File.join(AutoCopyDir, "default", "*")), prefix
##    FileUtils.cp_r Dir.glob(File.join(AutoCopyDir, Smithy::Config.arch, "*")), prefix
##
##    #case Smithy::Config.arch
##    #when "xk6"
##    #  FileUtils.cp File.join(SourcesDir, "titan.nodes"), prefix
##    #  FileUtils.cp File.join(SourcesDir, "system.config.titan"), File.join(prefix, "system.config")
##    #  FileUtils.cp File.join(SourcesDir, "remote-init.titan"), File.join(prefix, "remote-init")
##
##    #  FileUtils.rm_f(Dir.glob(File.join(prefix, "templates", "*"))) # Delete existing templates
##    #  FileUtils.cp File.join(SourcesDir, "titan.qtf"), File.join(prefix, "templates")
##    #  FileUtils.cp File.join(SourcesDir, "titan-gpu.qtf"), File.join(prefix, "templates")
##    #when "xc30"
##    #  FileUtils.cp File.join(SourcesDir, "remote-init.eos"), File.join(prefix, "remote-init")
##    #else
##    #  FileUtils.cp File.join(SourcesDir, "remote-init.default"), File.join(prefix, "remote-init")
##    #end
##  end
##
##
##  modulefile <<-MODULEFILE.strip_heredoc
##    #%Module
##    proc ModulesHelp { } {
##            puts stderr "Sets up the environment to use Allinea DDT <%= @package.version %>"
##    }
##    module-whatis "Sets up the environment to use Allinea DDT <%= @package.version %>"
##
##    <% if @package.build_name.include?("sles11") %>
##    ## Special notice that memory debugging has changed
##    if { [ module-info mode load ] } {
##        puts stderr " "
##        puts stderr "***NOTICE TO DDT USERS*** "
##        puts stderr "With version 4.0 (and later) of DDT, the procedure for memory debugging has "
##        puts stderr "changed.  You no longer need to compile with the ddtmem-cc, ddtmem-CC, "
##        puts stderr "and ddtmem-ftn scripts.  Rather, just load the ddt-memdebug module (in "
##        puts stderr "addition to this module) and compile as you normally would (with cc, "
##        puts stderr "CC and/or ftn).  The appropriate memory debugging libraries will be "
##        puts stderr "linked automatically. "
##        puts stderr " "
##        puts stderr "Please direct questions to help@olcf.ornl.gov "
##        puts stderr " "
##    }
##    setenv DDTMPIRUN <%= Smithy::Config.arch == "xc30" ? "/opt/cray/alps/default/bin/aprun" : "/usr/bin/aprun" %>
##    <% end %>
##
##    set ddt_version <%= @package.version %>
##    set apppath <%= @package.prefix %>
##    setenv DDT_HOME $apppath
##    setenv DDT_LICENSE_FILE /sw/sources/ddt/Licence
##    setenv MAP_LICENSE_FILE /sw/sources/ddt/Licence.map
##    prepend-path PATH $apppath/bin
##    prepend-path LD_LIBRARY_PATH $apppath/lib
##    prepend-path LD_LIBRARY_PATH  $apppath/lib/64
##  MODULEFILE
##end
####class DdtFormula < Formula
####  homepage "http://www.allinea.com"
####  url      "none"
####
####  SourcesDir = "/sw/sources/ddt"
####
####  def install
####    raise "You must specify a version" if version == "none"
####
####    if build_name.include?("sles11")
####      ddt_os = "Suse-11"
####    elsif build_name.include?("centos5")
####      ddt_os = "Redhat-5.7"
####    elsif build_name.include?("centos6")
####      ddt_os = "Redhat-6.0"
####    elsif build_name.include?("rhel6")
####      ddt_os = "Redhat-6.0"
####    else
####      raise "Unsupported build type"
####    end
####
####    tarfile = "allinea-tools-#{version}-#{ddt_os}-x86_64.tar"
####    system ["wget", "http://content.allinea.com/downloads/#{tarfile}"] unless File.exists?(tarfile)
####    system "tar -xf #{tarfile}"
####    FileUtils.rm tarfile
####    temp_dir_name = tarfile.chomp(".tar")
####    Dir.chdir temp_dir_name do |dirname|
####      system "./textinstall.sh --accept-licence #{prefix}"
####    end
####    FileUtils.rm_rf temp_dir_name
####
####    # Licence file used directly from sources dir (see module)
####    if build_name.include?("sles11")
####      FileUtils.cp File.join(SourcesDir, "titan.nodes"), prefix
####      FileUtils.cp File.join(SourcesDir, "system.config.titan"), prefix
####      FileUtils.cp File.join(SourcesDir, "remote-init.titan"), prefix
####
####      FileUtils.rm_rf(Dir.glob(File.join(prefix, "templates", "*"))) # Delete existing templates
####      FileUtils.cp File.join(SourcesDir, "titan.qtf"), File.join(prefix, "templates")
####      FileUtils.cp File.join(SourcesDir, "titan-gpu.qtf"), File.join(prefix, "templates")
####    end
####  end
####
####
####  modulefile <<-MODULEFILE.strip_heredoc
####    #%Module
####    proc ModulesHelp { } {
####            puts stderr "Sets up the environment to use Allinea DDT <%= @package.version %>"
####    }
####    module-whatis "Sets up the environment to use Allinea DDT <%= @package.version %>"
####
####    <% if @package.build_name.include?("sles11") %>
####    ## Special notice that memory debugging has changed
####    if { [ module-info mode load ] } {
####        puts stderr " "
####        puts stderr "***NOTICE TO DDT USERS*** "
####        puts stderr "With version 4.0 (and later) of DDT, the procedure for memory debugging has "
####        puts stderr "changed.  You no longer need to compile with the ddtmem-cc, ddtmem-CC, "
####        puts stderr "and ddtmem-ftn scripts.  Rather, just load the ddt-memdebug module (in "
####        puts stderr "addition to this module) and compile as you normally would (with cc, "
####        puts stderr "CC and/or ftn).  The appropriate memory debugging libraries will be "
####        puts stderr "linked automatically. "
####        puts stderr " "
####        puts stderr "Please direct questions to help@olcf.ornl.gov "
####        puts stderr " "
####    }
####    setenv DDTMPIRUN /usr/bin/aprun
####    <% else %>
####    set sys [ uname machine ]
####    prepend-path LD_LIBRARY_PATH  $apppath/lib/
####    <% end %>
####
####    set ddt_version <%= @package.version %>
####    set apppath <%= @package.prefix %>
####    setenv DDT_HOME $apppath
####    setenv DDT_LICENSE_FILE /sw/sources/ddt/Licence
####    setenv MAP_LICENSE_FILE /sw/sources/ddt/Licence.map
####    prepend-path PATH $apppath/bin
####    prepend-path LD_LIBRARY_PATH /opt$apppath/lib/64
####  MODULEFILE
####end
####
