class PythonMatplotlibFormula < Formula
  homepage "http://matplotlib.org/"

  supported_build_names /python.*numpy.*gnu.*/

  concern for_version("1.4.3") do
    included do
      url "https://pypi.python.org/packages/source/m/matplotlib/matplotlib-1.4.3.tar.gz"
      md5 "86af2e3e3c61849ac7576a6f5ca44267"
    end
  end

  concern for_version("1.4.0") do
    included do
      url "https://downloads.sourceforge.net/project/matplotlib/matplotlib/matplotlib-1.4.0/matplotlib-1.4.0.tar.gz"
    end
  end

  depends_on do
    python_module_from_build_name
  end

  #chose not to build with [ "python_pygtk" ]
  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if cray_system?

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    commands << "load #{pe}gnu"
    commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
    commands << "unload python"
    commands << "load #{python_module_from_build_name}"
    commands << "load python_numpy"
    commands << "load python_pygtk"
    commands << "load python_nose"
    commands
  end

  def install
    module_list

    unless build_name =~ /python3.3/
      File.open("setup.cfg", "w+") do |f|
        f.write <<-EOF.strip_heredoc
	  #Rename this file to setup.cfg to modify matplotlib's
	  # build options.

	  [egg_info]

	  [directories]
	  # Uncomment to override the default basedir in setupext.py.
	  # This can be a single directory or a comma-delimited list of directories.
	  #basedirlist = /usr

	  [status]
	  # To suppress display of the dependencies and their versions
	  # at the top of the build log, uncomment the following line:
	  #suppress = False

	  [packages]
	  # There are a number of subpackages of matplotlib that are considered
	  # optional.  They are all installed by default, but they may be turned
	  # off here.
	  #
	  #tests = True
	  #sample_data = True
	  #toolkits = True

	  [gui_support]
	  # Matplotlib supports multiple GUI toolkits, including Cocoa,
	  # GTK, Fltk, MacOSX, Qt, Qt4, Tk, and WX. Support for many of
	  # these toolkits requires AGG, the Anti-Grain Geometry library,
	  # which is provided by matplotlib and built by default.
	  #
	  # Some backends are written in pure Python, and others require
	  # extension code to be compiled. By default, matplotlib checks for
	  # these GUI toolkits during installation and, if present, compiles the
	  # required extensions to support the toolkit.
	  #
	  # - GTK 2.x support of any kind requires the GTK runtime environment
	  #   headers and PyGTK.
	  # - Tk support requires Tk development headers and Tkinter.
	  # - Mac OSX backend requires the Cocoa headers included with XCode.
	  # - Windowing is MS-Windows specific, and requires the "windows.h"
	  #   header.
	  #
	  # The other GUI toolkits do not require any extension code, and can be
	  # used as long as the libraries are installed on your system --
	  # therefore they are installed unconditionally.
	  #
	  # You can uncomment any the following lines to change this
	  # behavior. Acceptible values are:
	  #
	  #     True: build the extension. Exits with a warning if the
	  #           required dependencies are not available
	  #     False: do not build the extension
	  #     auto: build if the required dependencies are available,
	  #           otherwise skip silently. This is the default
	  #           behavior
	  #
	  gtk = True
	  #gtkagg = auto
	  #tkagg = auto
	  #macosx = auto
	  #windowing = auto
	  gtk3cairo = False
	  gtk3agg = False

	  [rc_options]
	  # User-configurable options
	  #
	  # Default backend, one of: Agg, Cairo, CocoaAgg, GTK, GTKAgg, GTKCairo,
	  # FltkAgg, MacOSX, Pdf, Ps, QtAgg, Qt4Agg, SVG, TkAgg, WX, WXAgg.
	  #
	  # The Agg, Ps, Pdf and SVG backends do not require external
	  # dependencies. Do not choose GTK, GTKAgg, GTKCairo, MacOSX, or TkAgg
	  # if you have disabled the relevent extension modules.  Agg will be used
	  # by default.
	  #
	  backend = GTK
	  #
        EOF
      end
    end
    system_python "setup.py install --prefix=#{prefix} --compile"
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
    module load python_numpy
    module load python_pygtk
    prereq python_numpy

    <%= python_module_build_list @package, @builds %>
    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
