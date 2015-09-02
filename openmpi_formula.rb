class OpenmpiFormula < Formula
  homepage "http://www.open-mpi.org"

  concern for_version("1.10.0") do
    included do
      url  "http://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.0.tar.gz"
      md5  "10e097bfaca8ed625781af0314797b90"
      sha1 "47e1b9acfd87fedea6cfdeea4c2c7f6db1ddf397"
    end
  end

  concern for_version("1.10.0-mtm") do
    included do
      url  "http://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.0.tar.gz"
      md5  "10e097bfaca8ed625781af0314797b90"
      sha1 "47e1b9acfd87fedea6cfdeea4c2c7f6db1ddf397"
    end
  end

  concern for_version("1.8.8") do
    included do
      url  "http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.8.tar.gz"
      md5  "88f2f6bf4a95df63a95d31cf31c20ebb"
      sha1 "d68561ad6dff1c6094590fe415ce892500e507c0"
    end
  end

  concern for_version("1.8.8-mtm") do
    included do
      url  "http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.8.tar.gz"
      md5  "88f2f6bf4a95df63a95d31cf31c20ebb"
      sha1 "d68561ad6dff1c6094590fe415ce892500e507c0"
    end
  end

  concern for_version("1.8.4") do
    included do
      url  "file:///sw/rhea/openmpi/1.8.4/openmpi-1.8.4.tar.gz"
      md5  "5bfd54d7fa54fa84c42ae6e297efc7b6"
      sha1 "22002fc226f55e188e21be0fdc3602f8d024e7ba"
    end
  end

  concern for_version("1.8.4-mtm") do
    included do
      url  "file:///sw/rhea/openmpi/1.8.4/openmpi-1.8.4.tar.gz"
      md5  "5bfd54d7fa54fa84c42ae6e297efc7b6"
      sha1 "22002fc226f55e188e21be0fdc3602f8d024e7ba"
    end
  end

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
    #system "./configure --prefix=#{prefix} --enable-static --with-verbs=yes --with-platform=optimized --enable-contrib-no-build=vt --enable-mca-no-build=btl-usnic --with-verbs-libdir=/usr/lib64 --with-mxm=/opt/mellanox/mxm --enable-mpi-thread-multiple"
   
    ## 20150902 - MPB - Old threaded configure string
    #system "./configure --prefix=#{prefix} --enable-static --with-verbs=yes --with-platform=optimized --enable-contrib-no-build=vt --enable-mca-no-build=btl-usnic --with-verbs-libdir=/usr/lib64 --enable-mpi-thread-multiple"
    
    ## 20150902 - MPB - Old default configure string
    #system "./configure --prefix=#{prefix} --enable-static --with-verbs=yes --with-platform=optimized --enable-contrib-no-build=vt --enable-mca-no-build=btl-usnic --with-verbs-libdir=/usr/lib64"
   
    options = [
      "--prefix=#{prefix}", "--enable-static", "--with-platform=optimized",
      "--enable-contrib-no-build=vt", "--enable-mca-no-build=btl-usnic"
    ]
    
    # If version has '-mtm' suffix, enable (less performant) mpi threading.
    options << "--enable-mpi-thread-multiple" if version =~ /mtm/

    # Build with verbs for systems with infiniband (not dtns, etc).
    if !(arch =~ /dtn/)
      options << "--with-verbs=yes"
      options << "--with-verbs-libdir=/usr/lib64"
    end

    system "./configure " + options.join(" ")
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

    <% if @builds.size > 1 %>
    <%= module_build_list @package, @builds %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    <% else %>
    set PREFIX <%= @package.prefix %>
    <% end %>

    setenv OMPI_DIR $PREFIX

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
    EOF
  end
end

