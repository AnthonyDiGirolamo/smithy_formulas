class PythonPygtkFormula < Formula
  homepage "http://pygtk.org/"

  supported_build_names "python2.7"

  concern for_version("2.10.6") do
    included do
      url "http://ftp.gnome.org/pub/GNOME/sources/pygtk/2.10/pygtk-2.10.6.tar.bz2"
    end
  end

  concern for_version("2.17.0") do
    included do
      url "http://ftp.gnome.org/pub/GNOME/sources/pygtk/2.17/pygtk-2.17.0.tar.bz2"
      sha256 "6a61817a2e765c6209c72ecdf44389ec134c1ebed1d842408bf001c9321f1400"
    end
  end

  params pygobject_module_name: "python_pygobject",
         pycairo_module_name:   "python_pycairo"

  depends_on do
    [ python_module_from_build_name,  pygobject_module_name, pycairo_module_name ]
  end

  module_commands do
    ["unload python", "load #{python_module_from_build_name}",
     "load #{pygobject_module_name}", "load #{pycairo_module_name}"]
  end

  def install
    module_list

    system "./configure --prefix=#{prefix} && make && make install"
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
    module load python_pygobject
    module load python_pycairo

    <%= python_module_build_list @package, @builds %>
    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PATH            $PREFIX/bin
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
    prepend-path LD_LIBRARY_PATH $PREFIX/lib/$LIBDIR/site-packages/gtk-2.0
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages/gtk-2.0
  MODULEFILE
end
