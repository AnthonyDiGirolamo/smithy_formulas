class PflotranFormula < Formula
  homepage "http://www.pflotran.org/"
  # url "https://bitbucket.org/pflotran/pflotran-release/get/tip.tar.gz"
  url "none"

  depends_on "petsc/dev/test*gnu4.7.2*"

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

    commands << "unload acml"
    commands << "load acml"

    if pe == "PrgEnv-"
      commands << "unload cray-hdf5 cray-hdf5-parallel hdf5 hdf5-parallel cray-tpsl"
      commands << "load cray-hdf5-parallel"
      commands << "load cray-tpsl"
    else
      commands << "unload hdf5 szip"
      commands << "load szip hdf5/1.8.11"
    end

    commands << "load mercurial"
    commands
  end

  def install
    module_list
    system "hg clone https://bitbucket.org/pflotran/pflotran-dev source" unless Dir.exists?("source")

    Dir.chdir File.join(prefix, "source")
    system "hg co 7321"

    Dir.chdir File.join(prefix, "source/src/pflotran")

    system "PETSC_DIR=#{petsc.prefix}/source HDF5_LIB=$HDF5_DIR/lib make clean pflotran"
  end
end
