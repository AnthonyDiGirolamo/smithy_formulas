class PythonYtFormula < Formula
  homepage "http://yt-project.org/doc/index.html"
  url "https://pypi.python.org/packages/source/y/yt/yt-3.0.tar.gz"
  md5 "c73c9ea79822208a6a373829175ab220"
  additional_software_roots [ config_value("lustre-software-root")[hostname] ]

  supported_build_names "python2.7", "python3"

  concern :Version3_0 do
    included do
      url "https://pypi.python.org/packages/source/y/yt/yt-3.0.tar.gz"
      md5 "c73c9ea79822208a6a373829175ab220"
    end
  end

  depends_on do
    [ python_module_from_build_name, "python_numpy/*/*#{python_version_from_build_name}*",
                                     "python_setuptools/*/*#{python_version_from_build_name}*",
                                     "python_cython/*/*#{python_version_from_build_name}*" ]
  end

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if cray_system?

    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    commands << "load #{pe}gnu"
    commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
    commands << "unload python"
    commands << "load #{python_module_from_build_name}"
    commands << "load python_numpy"
    commands << "load python_cython"
    commands << "load python_setuptools"
    commands
  end

  def install
    puts "#{python_module_from_build_name}"
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
    prereq python_numpy
    prereq PrgEnv-gnu PE-gnu
    prereq python_cython
    prereq python_matplotlib
    prereq python_h5py


    setenv PYTHON_YT_DIR "<%= @package.prefix %>"
    setenv PYTHON_YT_LIB "-L<%= @package.prefix %>/lib"
    setenv PYTHON_YT_INC "-I<%= @package.prefix %>/include"


    <%= python_module_build_list @package, @builds %>
    set PREFIX <%= @package.version_directory %>/$BUILD
    set LUSTREPREFIX #{additional_software_roots.first}/#{arch}/<%= @package.name %>/<%= @package.version %>/$BUILD
    prepend-path PYTHONPATH      $LUSTREPREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $LUSTREPREFIX/lib64/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib/$LIBDIR/site-packages
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
