class SipFormula < Formula
  homepage "http://sourceforge.net/projects/pyqt/files/sip/sip-4.17/sip-4.17.tar.gz"
  url "http://sourceforge.net/projects/pyqt/files/sip/sip-4.17/sip-4.17.tar.gz"

  supported_build_names /python2.7/

  depends_on do
    python_module_from_build_name
  end

  modules do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    mods = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    mods << "unload python"

    mods << "load #{pe}gnu"
    mods << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/

    mods << "load #{python_module_from_build_name}"
    mods
  end

  def install
    module_list
    system_python "configure.py ",
      "-b #{prefix}/bin ",
      "-d #{prefix}/lib64/$LIBDIR/site-packages ",
      "-e #{prefix}/include/$LIBDIR ",
      "-v #{prefix}/share"
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
    module load sip
    prereq sip

    <%= python_module_build_list @package, @builds %>
    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PATH            $PREFIX/bin
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
    prepend-path INCLUDE_PATH    $PREFIX/include/$LIBDIR
  MODULEFILE
end
