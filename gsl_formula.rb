class GslFormula < Formula
  homepage 'http://www.gnu.org/software/gsl/'
  url 'http://ftpmirror.gnu.org/gsl/gsl-1.15.tar.gz'
  sha1 'd914f84b39a5274b0a589d9b83a66f44cd17ca8e'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make install"
  end

  modulefile <<-EOF.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    <% if @builds.size > 1 %>
    <%= module_build_list @package, @builds %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    <% else %>
    set PREFIX <%= @package.prefix %>
    <% end %>

    setenv       GSL_DIR            $PREFIX
    set          GSL_INCLUDE_PATH   "-I$PREFIX/include"
    set          GSL_LD_OPTS        "-L$PREFIX/lib -lgsl -lgslcblas"
    setenv       GSL_LIB            "$GSL_INCLUDE_PATH $GSL_LD_OPTS"

    prepend-path PATH               $PREFIX/bin
    prepend-path PE_PRODUCT_LIST    "GSL"
    setenv       GSL_INCLUDE_OPTS   "-I$PREFIX/include"
    setenv       GSL_POST_LINK_OPTS "-L$PREFIX/lib -lgsl -lgslcblas"
  EOF
end
