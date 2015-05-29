class PythonPygobjectFormula < Formula
  homepage "http://pygtk.org/"

  supported_build_names "python2.7", "python3"

  concern for_version("2.12.3") do
    included do
      url "http://ftp.gnome.org/pub/GNOME/sources/pygobject/2.12/pygobject-2.12.3.tar.bz2"
    end
  end

  concern for_version("2.20.0") do
    included do
      url "http://ftp.gnome.org/pub/GNOME/sources/pygobject/2.20/pygobject-2.20.0.tar.bz2"
      sha256 "41e923a3f4426a3e19f6d154c424e3dac6f39defca77af602ac6272ce270fa81"
    end
  end

  # the newest version 3.10.x branch complains about GLIB
  concern for_version("2.28.6") do
    included do
      url "http://ftp.gnome.org/pub/GNOME/sources/pygobject/2.28/pygobject-2.28.6.tar.bz2"
      sha256 "e4bfe017fa845940184c82a4d8949db3414cb29dfc84815fb763697dc85bdcee"
    end
  end

  depends_on do
    [ python_module_from_build_name ]
  end

  module_commands do
    ["unload python", "load #{python_module_from_build_name}"]
  end

  def install
    module_list

    python_version = get_python_version_from_build_name(build_name)

    incdir = "#{python.prefix}/include/#{python_libdir(python_version)}"

    # for some reason the python/3.4.3 include directory has an extra m
    incdir = incdir + "m" unless python_version =~ /python2/
    ENV["CPPFLAGS"] = "-I#{incdir}"

    system "./configure --prefix=#{prefix} --disable-introspection && make && make install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    prereq python

    <%= python_module_build_list @package, @builds %>
    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib64
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages/gtk-2.0

  MODULEFILE
end
