class PythonNoseFormula < Formula
  homepage "https://nose.readthedocs.org/en/latest"
  url "https://pypi.python.org/packages/source/n/nose/nose-1.3.4.tar.gz"
  md5 "6ed7169887580ddc9a8e16048d38274d"

  supported_build_names "python2.7", "python3"

  depends_on do
    build_name_python
  end

  module_commands do
    ["unload python", "load #{build_name_python}"]
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

    <% if @builds.size > 1 %>
    <%= python_module_build_list @package, @builds %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    <% else %>
    set PREFIX <%= @package.prefix %>
    <% end %>

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib64
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
  MODULEFILE
end
