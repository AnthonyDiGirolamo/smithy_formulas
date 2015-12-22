class NwchemFormula < Formula
  homepage "http://www.nwchem-sw.org/"
  url "http://www.nwchem-sw.org/download.php?f=Nwchem-6.6.revision27746-src.2015-10-20.tar.gz"

  params nwchem_target: "LINUX64"

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
    commands << "load cudatoolkit" if module_is_available?("cudatoolkit")
    commands
  end

  def install
    module_list

    # Use the compiler wrappers
    ENV["CC"] = "cc"
    ENV["FC"] = "ftn"

    ENV["NWCHEM_TOP"] = "#{prefix}"
    ENV["NWCHEM_TARGET"] = "#{nwchem_target}"
    ENV["NWCHEM_MODULES"] = "all"

    case build_name
    when /pgi/
      compiler = "pgi"
    when /gnu/
      compiler = "gnu"
    when /intel/
      compiler = "intel"
    when /cray/
      compiler = "cray"
    end

    ENV["ARMCI_NETWORK"] = "MPI-PR"
    ENV["USE_64TO32"] = "y"
    ENV["USE_MPI"] = "y"
    ENV["BLAS_SIZE"] = "4"
    ENV["LAPACK_SIZE"] = "4"
    ENV["SCALAPACK_SIZE"] = "4"
    ENV["SCALAPACK"] = "-lsci_#{compiler}_mp"
    ENV["BLASOPT"] = "-lsci_#{compiler}_mp"
    ENV["TCE_CUDA"] = "y" if module_is_available?("cudatoolkit")

    system "ln -svf #{prefix}/source/src #{prefix}/src"
    Dir.chdir("#{prefix}/src")
    system "make nwchem_config"
    system "make"
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

    set TARGET "#{nwchem_target}"

    setenv NWCHEM_TOP            $PREFIX
    setenv NWCHEM_TARGET         $TARGET

    prepend-path LD_LIBRARY_PATH $PREFIX/lib/$TARGET
    prepend-path PATH            $PREFIX/bin/$TARGET
  EOF
end
