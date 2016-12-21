class PythonMatplotlibBasemapToolkitFormula < Formula
  homepage "http://matplotlib.org/basemap/index.html"
  supported_build_names /python.*numpy.*gnu.*/
  url "http://downloads.sourceforge.net/project/matplotlib/matplotlib-toolkits/basemap-1.0.7/basemap-1.0.7.tar.gz"
  md5 "48c0557ced9e2c6e440b28b3caff2de8"

  depends_on do
    [python_module_from_build_name, "python_numpy", "geos"]
  end

  module_commands do
    vendors = %W(gnu pgi cray intel)
    prefix = module_is_available?("PrgEnv-gnu") ? "PrgEnv" : "PE"
    commands = vendors.map{|vendor| "unload #{prefix}-#{vendor}"}
    commands << "load #{prefix}-gnu"
    
    commands << "unload python"
    commands << "load #{python_module_from_build_name}"
    commands << "load geos"
    commands << "load python_numpy/1.9.2"
    commands << "load python_matplotlib/1.4.3"
  end

  def install
    system "GEOS_DIR=#{geos.prefix} python setup.py install --prefix=#{prefix}"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    prereq PrgEnv-gnu PE-gnu
    prereq python
    prereq geos
    prereq python_numpy/1.9.2
    prereq python_matplotlib/1.4.3

    
    <%= python_module_build_list @package, @builds %>
    set BUILD  <%= @package.build_name %>
    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
