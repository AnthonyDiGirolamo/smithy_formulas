class PythonNumexprFormula < Formula
  homepage "http://code.google.com/p/numexpr/"
  url "http://numexpr.googlecode.com/files/numexpr-2.2.2.tar.gz"
  sha1 "021cbd31e6976164b4b956318b30630dabd16159"

  depends_on do
    [ python_module_from_build_name ]
  end

  module_commands do
    commands = ["unload python"]
    commands << "load #{python_module_from_build_name}"
    commands << "load python_numpy"
  end

  def install
    module_list

    system_python "setup.py build"
    system_python "setup.py install --prefix=#{prefix} --compile"
  end

  modulefile <<-MODULEFILE
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    module load python_numpy
    prereq python_numpy

    <%= python_module_build_list @package, @builds %>
    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages

    prepend-path PYTHONPATH      /opt$PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      /opt$PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
