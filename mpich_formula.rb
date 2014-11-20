class MpichFormula < Formula
  homepage "http://www.mpich.org"
  url      "http://www.mpich.org/static/downloads/3.1/mpich-3.1.tar.gz"

  module_commands do
    commands = [ "purge" ]
    case build_name
    when /gnu/
      commands << "load gcc"
      commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
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
    if build_name =~ /gnu/
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

    system "./configure --prefix=#{prefix} --with-pbs=/var/spool/torque"
    system "make"
    system "make install"

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

    if [ is-loaded gcc ] {
      set BUILD rhel6_gnu4.7.1
    } elseif [ is-loaded pgi/13.9 ] {
      set BUILD rhel6_pgi13.9
    } elseif [ is-loaded pgi/13.4 ] {
      set BUILD rhel6_pgi13.4
    } elseif [ is-loaded pgi/12.8 ] {
      set BUILD rhel6_pgi12.8
    } elseif [ is-loaded pgi ] {
      set BUILD rhel6_pgi13.4
    } elseif [ is-loaded intel/13.1.3 ] {
      set BUILD rhel6_intel13.1.3
    } elseif [ is-loaded intel/11.1.072 ] {
      set BUILD rhel6_intel11.1.072
    } elseif [ is-loaded intel ] {
      set BUILD rhel6_intel11.1.072
    }

    if {![info exists BUILD] && [lsearch -nocase {remove switch switch1 switch2 switch3} [module-info mode]] == -1 } {
      puts stderr "[module-info name] is only available for the following environments:"
      puts stderr "rhel6_gnu4.7.1"
      puts stderr "rhel6_intel11.1.072"
      puts stderr "rhel6_intel13.1.3"
      puts stderr "rhel6_pgi12.8"
      puts stderr "rhel6_pgi13.4"
      puts stderr "rhel6_pgi13.9"
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

