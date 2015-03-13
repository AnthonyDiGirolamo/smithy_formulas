class PythonScipyFormula < Formula
  homepage "http://www.scipy.org"
  url "http://downloads.sourceforge.net/project/scipy/scipy/0.15.1/scipy-0.15.1.tar.gz"

  supported_build_names "python2.7", "python3"

  depends_on do
    build_name_python
  end

  module_commands do
    ["unload python",
     "load #{build_name_python}",
     "load python_numpy/1.9.2",
     "load gcc"]
  end

  def install
    module_list

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
    prereq python_numpy

    <% if @builds.size > 1 %>
    <%= python_module_build_list @package, @builds %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    <% else %>
    set PREFIX <%= @package.prefix %>
    <% end %>

    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
