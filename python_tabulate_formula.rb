class PythonTabulateFormula < Formula
  homepage "https://pypi.python.org/pypi/tabulate"
  url "https://pypi.python.org/packages/source/t/tabulate/tabulate-0.7.3.tar.gz#md5=d6664ca3e27e17a55ef5dec8177cb24d"
  md5 "d6664ca3e27e17a55ef5dec8177cb24d"

  def install
    module_list
    system "python setup.py install --prefix=#{prefix}"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    set BUILD python2.6.8
    set LIBDIR python2.6
    set PREFIX <%= @package.version_directory %>/$BUILD

    prepend-path PATH            $PREFIX/bin
    prepend-path PYTHONPATH      $PREFIX/lib64/$LIBDIR/site-packages
  MODULEFILE
end
