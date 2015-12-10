class LibdwarfFormula < Formula
  homepage "http://sourceforge.net/projects/libdwarf/"
  url "https://github.com/Distrotech/libdwarf/archive/20150507.tar.gz"
  md5 "7b80e1c717850de6ca003d1e909b588c"
  version "20150507"
 
  depends_on [ "libelf","mpc" ]

  module_commands [
    "unload PrgEnv-cray PrgEnv-gnu PrgEnv-intel PrgEnv-pathscale PrgEnv-pgi",
    "load PrgEnv-gnu mpc"
  ]

  def install
    module_list

    # setup build config
    ENV['CC'] = "gcc"
    ENV['CXX'] = "g++"
    libelf_inc = module_environment_variable("libelf", "LIBELF_INC")
    libelf_lib = module_environment_variable("libelf", "LIBELF_LIB")
    config_cmd = [
      "./configure --prefix=#{prefix} --enable-shared",
      "LDFLAGS=\"#{libelf_lib}\"",
      "CFLAGS=\"#{libelf_inc}\"",
      "CXXFLAGS=\"#{libelf_inc}\""
    ]

    # build libdwarf and dwarfdump libraries
    libdwarf_buildpath = "#{prefix}/source/libdwarf-#{version}/"
    #Dir.chdir libdwarf_buildpath 
    system config_cmd
    ENV['LD_LIBRARY_PATH'] = ENV['LD_LIBRARY_PATH'] + ":" + libdwarf_buildpath
    system "LD_LIBRARY_PATH=#{ENV['LD_LIBRARY_PATH'] + ":" + libdwarf_buildpath + "libdwarf"} make dd"

    # installation prep
    install_bin = prefix+"/bin"
    install_inc = prefix+"/include"
    install_lib = prefix+"/lib"
    install_man = prefix+"/share/man/man1"
    FileUtils.mkdir_p install_bin
    FileUtils.mkdir_p install_inc
    FileUtils.mkdir_p install_lib
    FileUtils.mkdir_p install_man

    # install libraries
    Dir.chdir prefix+"/source/libdwarf-#{version}/libdwarf"
    FileUtils.install 'libdwarf.a', install_lib, :mode => 0644
    FileUtils.install 'libdwarf.so', install_lib, :mode => 0755

    # install headers
    FileUtils.install %w{ dwarf.h libdwarf.h }, install_inc, :mode => 0644

    # install executables
    Dir.chdir prefix+"/source/libdwarf-#{version}/dwarfdump"
    FileUtils.install 'dwarfdump', install_bin, :mode => 0755
    FileUtils.install 'dwarfdump.conf', install_lib, :mode => 0644
    FileUtils.install 'dwarfdump.1', install_man, :mode => 0644
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    module load libelf

    set PREFIX <%= @package.prefix %>

    # Helpful ENV Vars
    setenv LIBDWARF_DIR $PREFIX
    setenv LIBDWARF_LIB "-L$PREFIX/lib"
    setenv LIBDWARF_INC "-I$PREFIX/include"

    # Common Paths
    prepend-path PATH            $PREFIX/bin
    prepend-path LIBRARY_PATH    $PREFIX/lib
    prepend-path LD_LIBRARY_PATH $PREFIX/lib
    prepend-path MANPATH         $PREFIX/share/man
  MODULEFILE
end
