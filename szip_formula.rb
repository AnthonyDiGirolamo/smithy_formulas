class SzipFormula < Formula
  homepage "http://www.hdfgroup.org/doc_resource/SZIP/"
  url      "http://www.hdfgroup.org/ftp/lib-external/szip/2.1/src/szip-2.1.tar.gz"
  md5      "9229ef21fe4471281f0b632eb70376b1"

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")

    m = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    case build_name
    when /gnu/
      m << "load #{pe}gnu"
    when /pgi/
      m << "load #{pe}pgi"
    when /intel/
      m << "load #{pe}intel"
    when /cray/
      m << "load #{pe}cray"
    end
  end

  def install
    module_list

    case build_name
    when /gnu/
      ENV["CC"]  = "gcc"
      ENV["CXX"] = "g++"
      ENV["F77"] = "gfortran"
      ENV["FC"]  = "gfortran"
      ENV["LDFLAGS"] = "-lm"
    when /intel/
      ENV["CC"]  = "icc"
      ENV["CXX"] = "icpc"
      ENV["F77"] = "ifort"
      ENV["FC"]  = "ifort"
    when /pgi/
      ENV["CC"]  = "pgcc"
      ENV["CXX"] = "pgCC"
      ENV["F77"] = "pgf77"
      ENV["FC"]  = "pgf90"
    when /cray/
      ENV["CC"]  = "cc"
      ENV["CXX"] = "CC"
      ENV["F77"] = "ftn"
      ENV["FC"]  = "ftn"
    end

    system "./configure --prefix=#{prefix} --enable-static --enable-shared"
    system "make"
    system "make install"
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

      <% if @builds.size > 1 %>
      <%= module_build_list @package, @builds, :prgenv_prefix => #{module_is_available?("PrgEnv-gnu") ? '"PrgEnv-"' : '"PE-"'} %>

      set PREFIX <%= @package.version_directory %>/$BUILD
      <% else %>
      set PREFIX <%= @package.prefix %>
      <% end %>

      set    SZIP_INCLUDE_PATH "-I$PREFIX/include"
      set    SZIP_LD_OPTS      "-L$PREFIX/lib -lsz"
      setenv SZIP_LIB          "$SZIP_INCLUDE_PATH $SZIP_LD_OPTS"
      setenv SZIP_DIR          "${PREFIX}"

      # Use Cray magic to link against automagically
      prepend-path PE_PRODUCT_LIST     "SZIP"
      setenv       SZIP_INCLUDE_OPTS   "-I$PREFIX/include"
      setenv       SZIP_POST_LINK_OPTS "-L$PREFIX/lib -lsz"
    MODULEFILE
  end
end
