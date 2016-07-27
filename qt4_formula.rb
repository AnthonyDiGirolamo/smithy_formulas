class QtFormula < Formula
  homepage "http://qt-project.org/"
  url "http://download.qt.io/official_releases/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz"
  sha256 "e2882295097e47fe089f8ac741a95fef47e0a73a3f3cdf21b56990638f626ea0"

  module_commands do
    [ "purge" ]
  end

  def install
    module_list
    system "./configure --prefix=#{prefix}",
      "-system-libpng", "-system-zlib",
      "-confirm-license", "-opensource"
    system "make"
    system "make install"
  end

  modulefile do
  <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set PREFIX <%= @package.prefix %>

    prepend-path PATH $PREFIX/bin
    prepend-path PYTHONPATH $PREFIX/lib/site-packages
    prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
  MODULEFILE
  end
end
