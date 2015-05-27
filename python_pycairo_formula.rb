class PythonPycairoFormula < Formula
  homepage "http://cairographics.org/pycairo/"

  supported_build_names "python2.7"
  # need at least cairo version == pycairo tarball
  # does not seem to work for python3

  params pygobject_module_name: "python_pygobject"

  concern for_version("1.2.0") do
    included do
      url "http://cairographics.org/releases/pycairo-1.2.0.tar.gz"
    end
  end

  concern for_version("1.8.8") do
    included do
      url "http://cairographics.org/releases/pycairo-1.8.8.tar.gz"
      md5 "054da6c125cb427a003f5fd6c54f853e"
    end
  end

  depends_on do
    [ python_module_from_build_name, "#{pygobject_module_name}/*/#{python_version_from_build_name}*" ]
  end

  module_commands do
    ["unload python", "load #{python_module_from_build_name}", "load #{pygobject_module_name}"]
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

    module load #{pygobject_module_name}
    prereq #{pygobject_module_name}

    <%= python_module_build_list @package, @builds %>
    set PREFIX <%= @package.version_directory %>/$BUILD

    set LUSTREPREFIX /lustre/atlas/sw/xk7/<%= @package.name %>/<%= @package.version %>/$BUILD

    prepend-path PYTHONPATH      $LUSTREPREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $LUSTREPREFIX/lib64/$LIBDIR/site-packages

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib64
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages

  MODULEFILE
end
