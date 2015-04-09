class PythonNoseFormula < Formula
  homepage "https://nose.readthedocs.org/en/latest"
  url "https://pypi.python.org/packages/source/n/nose/nose-1.3.4.tar.gz"
  md5 "6ed7169887580ddc9a8e16048d38274d"
  additional_software_roots [ config_value("lustre-software-root")[Smithy::Config.hostname] ]

  supported_build_names "python2.7", "python3"

  depends_on do
    python_module_from_build_name
  end

  module_commands do
    ["unload python", "load #{python_module_from_build_name}"]
  end

  def install
    module_list
    system_python "setup.py install --prefix=#{prefix} --compile"
  end

  modulefile do
    <<-MODULEFILE.strip_heredoc
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
      set LUSTREPREFIX #{additional_software_roots.first}/#{arch}/<%= @package.name %>/<%= @package.version %>/$BUILD
  
      prepend-path PYTHONPATH      $LUSTREPREFIX/lib/$LIBDIR/site-packages
      prepend-path PYTHONPATH      $LUSTREPREFIX/lib64/$LIBDIR/site-packages
  
      prepend-path PATH            $PREFIX/bin
      prepend-path LD_LIBRARY_PATH $PREFIX/lib
      prepend-path LD_LIBRARY_PATH $PREFIX/lib64
      prepend-path MANPATH         $PREFIX/share/man
      prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    MODULEFILE
  end
end
