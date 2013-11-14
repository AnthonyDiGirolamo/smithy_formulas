class HypreFormula < Formula
  homepage "http://computation.llnl.gov/casc/hypre/software.html"
  url "http://computation.llnl.gov/casc/hypre/download/hypre-2.9.0b.tar.gz"
  md5 "87bce8469240dc775c6c622c5f68fa87"

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if module_is_available?("PrgEnv-gnu")
    commands = [ "unload #{pe}gnu #{pe}pgi #{pe}cray #{pe}intel" ]
    case build_name
    when /gnu/
      commands << "load #{pe}gnu"
      commands << "swap gcc gcc/#{$1}" if build_name =~ /gnu([\d\.]+)/
    when /pgi/
      commands << "load #{pe}pgi"
      commands << "swap pgi pgi/#{$1}" if build_name =~ /pgi([\d\.]+)/
    when /intel/
      commands << "load #{pe}intel"
      commands << "swap intel intel/#{$1}" if build_name =~ /intel([\d\.]+)/
    when /cray/
      commands << "load #{pe}cray"
      commands << "swap cce cce/#{$1}" if build_name =~ /cray([\d\.]+)/
    end
    commands
  end

  def install
    if module_is_available?("PrgEnv-gnu")
      ENV["CC"] = "cc"
      ENV["CXX"] = "CC"
      ENV["F77"] = "ftn"
    else
      ENV["CC"] = "mpicc"
      ENV["CXX"] = "mpiCC"
      ENV["F77"] = "mpif77"
    end

    Dir.chdir "src"

    module_list
    system "./configure --prefix=#{prefix} --with-no-global-partition"
    system "make"
    system "make install"
  end

  modulefile do
    <<-MODULEFILE.strip_heredoc
      #%Module
      proc ModulesHelp { } {
        puts stderr "Sets up environment to use Hypre with any compiler."
        puts stderr "Usage:   mpicc test.f90 \${HYPRE_LIB} "
        puts stderr "    or   cc test.c \${HYPRE_LIB}"
        puts stderr "The hypre module must be reloaded if you change the PrgEnv"
        puts stderr "or you must issue a 'module update' command."
      }
      # One line description
      module-whatis "<%= @package.name %> <%= @package.version %>"

      <% if @builds.size > 1 %>
      <%= module_build_list @package, @builds, :prgenv_prefix => #{module_is_available?("PrgEnv-gnu") ? '"PrgEnv-"' : '"PE-"'} %>

      set PREFIX <%= @package.version_directory %>/$BUILD
      <% else %>
      set PREFIX <%= @package.prefix %>
      <% end %>

      setenv HYPRE_DIR          $PREFIX
      set    HYPRE_INCLUDE_PATH "-I$PREFIX/include"
      set    HYPRE_LD_OPTS      "-L$PREFIX/lib -lHYPRE"
      setenv HYPRE_LIB          "$HYPRE_INCLUDE_PATH $HYPRE_LD_OPTS"
    MODULEFILE
  end
end
