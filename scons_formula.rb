class SconsFormula < Formula
  homepage "http://www.scons.org"
  url "http://downloads.sourceforge.net/project/scons/scons/2.3.0/scons-2.3.0.tar.gz"

  depends_on do
    case build_name
    when /python3.3/
      [ "python/3.3.0" ]
    when /python2.7/
      [ "python/2.7.9" ]
    end
  end

  modules do
    case build_name
    when /python3.3/
      [ "python/3.3.0" ]
    when /python2.7/
      [ "python/2.7.9" ]
    end
  end

  def install
    module_list
    python_binary = "python"
    libdirs = []
    case build_name
    when /python3.3/
      python_binary = "python3.3"
      libdirs << "#{prefix}/lib/python3.3/site-packages"
    when /python2.7/
      libdirs << "#{prefix}/lib/python2.7/site-packages"
    when /python2.6/
      libdirs << "#{prefix}/lib64/python2.6/site-packages"
    end
    FileUtils.mkdir_p libdirs.first

    system "PYTHONPATH=$PYTHONPATH:#{libdirs.join(":")} #{python_binary} setup.py install --prefix=#{prefix}"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    prereq python
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    <%= python_module_build_list @package, @builds %>
    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PATH            $PREFIX/bin
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib64
    prepend-path MANPATH         $PREFIX/share/man
    prepend-path PYTHONPATH      $PREFIX/lib/scons-2.3.0
    prepend-path PYTHONPATH      $PREFIX/lib64/scons-2.3.0
  MODULEFILE
end
