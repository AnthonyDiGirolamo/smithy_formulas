class PythonFireworksFormula < Formula
  homepage "https://pythonhosted.org/FireWorks/"
  url "https://github.com/materialsproject/fireworks/archive/v1.04.tar.gz"
  md5  "c34efc9ff2880bd23f5603e5aabed84b"

  supported_build_names /python2.7/, /python3/

  depends_on do
    python_module_from_build_name
  end

  modules do
    mods = []
    mods << python_module_from_build_name
    mods << "python_setuptools"
    mods
  end

  def install
    module_list
    
    patch <<-EOF.strip_heredoc
      diff --git a/setup.py b/setup.py
      --- a/setup.py    2015-01-20 16:03:16.000000000 -0500
      +++ b/setup.py    2015-05-07 11:19:01.072917000 -0400
      @@ -26,7 +26,7 @@
               packages=find_packages(),
               package_data={'fireworks.user_objects.queue_adapters': ['*.txt'], 'fireworks.user_objects.firetasks': ['templates/*.txt'], 'fireworks.flask_site': ['static/images/*', 'static/css/*', 'templates/*']},
               zip_safe=False,
      -        install_requires=['pyyaml>=3.1.0', 'pymongo>=2.4.2', 'Jinja2>=2.7.3',
      +        install_requires=['pyyaml>=3.1.0', 'pymongo<=2.8', 'Jinja2>=2.7.3',
                                 'six>=1.5.2', 'monty>=0.5.6', 'python-dateutil>=2.2'],
               extras_require={'rtransfer': ['paramiko>=1.11'],
                               'newt': ['requests>=2.01'],
    EOF

    system_python "setup.py develop --prefix=#{prefix}"
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
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
