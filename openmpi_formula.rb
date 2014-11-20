class OpenmpiFormula < Formula
  homepage "http://www.open-mpi.org"
  #url      "http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.3.tar.gz"
  url      "file:///sw/rhea/openmpi/1.8.3-mtm/openmpi-1.8.3.tar.gz"
  md5      "167f4e8e2291ea0349e3dbe9fba13829"
  sha1     "3bffe4826b4658efd7fcdf961ecd8be275e8af43"
  #url      "file:///sw/rhea/openmpi/1.8.2-mtm/openmpi-1.8.2.tar.gz"
  #md5      "ab538ed8e328079d566fc797792e016e"
  #sha1     "cf2b1e45575896f63367406c6c50574699d8b2e1"
  #version  "1.8.2-mtm"

  module_commands do
    commands = [ "purge" ]
    case build_name
    when /gcc/
      commands << "load gcc"
      commands << "swap gcc gcc/#{$1}" if build_name =~ /gcc([\d\.]+)/
    when /pgi/
      commands << "load pgi"
      commands << "swap pgi pgi/#{$1}" if build_name =~ /pgi([\d\.]+)/
    when /intel/
      commands << "load intel"
      commands << "swap intel intel/#{$1}" if build_name =~ /intel([\d\.]+)/
    end
    commands
  end

  def install
    if build_name =~ /gcc/
      ENV["CC"]  = "gcc"
      ENV["CXX"] = "g++"
      ENV["F77"] = "gfortran"
      ENV["FC"]  = "gfortran"
    elsif build_name =~ /intel/
      ENV["CC"]  = "icc"
      ENV["CXX"] = "icpc"
      ENV["F77"] = "ifort"
      ENV["FC"]  = "ifort"
    elsif build_name =~ /pgi/
      ENV["CC"]  = "pgcc"
      ENV["CXX"] = "pgCC"
      ENV["F77"] = "pgf77"
      ENV["FC"]  = "pgf90"
    end

    module_list

    #Dir.chdir prefix+"/source"
    #old####system "./configure --prefix=#{prefix} --with-platform=optimized --enable-static --enable-contrib-no-build=vt --enable-mpi-thread-multiple --with-verbs=yes --enable-mca-no-build=btl-usnic --with-verbs-libdir=/usr/lib64"
    #system "./configure --prefix=#{prefix} --enable-static --with-verbs=yes --with-platform=optimized --enable-contrib-no-build=vt --enable-mca-no-build=btl-usnic --with-verbs-libdir=/usr/lib64 --with-mxm=/opt/mellanox/mxm"
    system "./configure --prefix=#{prefix} --enable-static --with-verbs=yes --with-platform=optimized --enable-contrib-no-build=vt --enable-mca-no-build=btl-usnic --with-verbs-libdir=/usr/lib64"# --with-mxm=/opt/mellanox/mxm --enable-mpi-thread-multiple"
    system "make -j4"
    system "make install"

    notice "Double check that the linker flags are correct in these files: ./share/openmpi/mpi**-wrapper-data.txt"
  end

  modulefile do
    <<-EOF.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    if [ is-loaded gcc/4.7.1 ] {
      set BUILD rhel6.6_gcc4.7.1
    } elseif [ is-loaded gcc/4.8.2 ] {
      set BUILD rhel6.6_gcc4.8.2
    } elseif [ is-loaded gcc ] {
      set BUILD rhel6.6_gcc4.8.2
    } elseif [ is-loaded pgi/13.1.3 ] {
      set BUILD rhel6.6_pgi13.1.3
    } elseif [ is-loaded pgi/14.4 ] {
      set BUILD rhel6.6_pgi14.4
    } elseif [ is-loaded pgi ] {
      set BUILD rhel6.6_pgi14.4
    } elseif [ is-loaded intel/14.0.4 ] {
      set BUILD rhel6.6_intel14.0.4
    } elseif [ is-loaded intel/13.1.3 ] {
      set BUILD rhel6.6_intel13.1.3
    } elseif [ is-loaded intel ] {
      set BUILD rhel6.6_intel14.0.4
    }

    if {![info exists BUILD] && [lsearch -nocase {remove switch switch1 switch2 switch3} [module-info mode]] == -1 } {
      puts stderr "[module-info name] is only available for the following environments:"
      puts stderr "rhel6.6_gcc4.8.2"
      puts stderr "rhel6.6_gcc4.7.1"
      puts stderr "rhel6.6_intel13.1.3"
      puts stderr "rhel6.6_intel14.0.4"
      puts stderr "rhel6.6_pgi14.4"
      puts stderr "rhel6.6_pgi13.4"
      break
    }

    if {[info exists BUILD]} {
      set PREFIX <%= @package.version_directory %>/$BUILD

      setenv OMPI_DIR $PREFIX

      prepend-path PATH            $PREFIX/bin
      prepend-path LD_LIBRARY_PATH $PREFIX/lib
      prepend-path MANPATH         $PREFIX/share/man
      prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
    }
    EOF
  end
end

