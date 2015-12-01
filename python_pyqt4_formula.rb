class PythonPyqt4Formula < Formula
  homepage "https://www.riverbankcomputing.com/software/pyqt/intro"
  url "http://sourceforge.net/projects/pyqt/files/PyQt4/PyQt-4.11.4/PyQt-x11-gpl-4.11.4.tar.gz"

  supported_build_names "python2.7"

  depends_on do
    [python_module_from_build_name,
     "sip"]
  end

  module_commands do
    ["unload python",
     "load #{python_module_from_build_name}",
     "load qt4",
     "load sip"]
  end

  def install
    module_list

    system_python "configure.py ",
      "-b #{prefix}/bin ",
      "-d #{prefix}/lib/$LIBDIR/site-packages "
    system "make"
    system "make install"
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
    module load qt4
    prereq qt4
    module load sip
    prereq sip

    <%= python_module_build_list @package, @builds %>
    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PATH            $PREFIX/bin
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
  MODULEFILE
end
