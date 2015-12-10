class TbbFormula < Formula
  homepage "https://www.threadingbuildingblocks.org"
  url "https://www.threadingbuildingblocks.org/sites/default/files/software_releases/source/tbb44_20150728oss_src.tgz"

  def install
    module_list
    system "compiler=gcc tbb_build_prefix=#{prefix} && make"

    tbb_prefix=Dir["#{prefix}/source/build/linux_*_release"].first

    # Create pkg-config file as one is not distrubted with OpenVDB
    system "mkdir #{prefix}/source/build/pkgconfig"
    File.open("#{prefix}/source/build/pkgconfig/tbb.pc", "w+") do |f|
      f.write <<-EOF.strip_heredoc
        openvdb.pc:
        prefix=#{prefix}/source/
        exec_prefix=#{tbb_prefix}
        includedir=${prefix}/include
        libdir=${exec_prefix}

        Name: #{package.name}
        Description: TBB development library
        Version: #{package.version}
        Cflags: -I${includedir}
        Libs: -L${libdir} -ltbb -ltbbmalloc
      EOF
    end
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>/source/build

    setenv TBB_PATH $PREFIX
    prepend-path PKG_CONFIG_PATH $PREFIX/pkgconfig
  MODULEFILE
end
