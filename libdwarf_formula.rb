class LibdwarfFormula < Formula
  homepage "http://sourceforge.net/projects/libdwarf/"
  url "none"
  version "20130729-b"
 
  depends_on [ "libelf" ]

  module_commands [
    "unload PrgEnv-cray PrgEnv-gnu PrgEnv-intel PrgEnv-pathscale PrgEnv-pgi",
    "load PrgEnv-gnu",
    "load git"
  ]

  def install
    module_list

    # checkout specified version of source code
    system "git clone http://git.code.sf.net/p/libdwarf/code source" unless Dir.exists?("source")
    Dir.chdir prefix+"/source"
    system "git reset --hard"
    system "git checkout #{version}"

    # setup build config
    ENV['CC'] = "cc --target=native"
    ENV['CXX'] = "CC --target=native"
    libelf_inc = module_environment_variable("libelf", "LIBELF_INC")
    libelf_lib = module_environment_variable("libelf", "LIBELF_LIB")
    config_cmd = [
      "./configure --prefix=#{prefix} --enable-shared",
      "LDFLAGS=\"#{libelf_lib}\"",
      "CFLAGS=\"#{libelf_inc}\"",
      "CXXFLAGS=\"#{libelf_inc}\""
    ]

    # build libdwarf libraries
    Dir.chdir prefix+"/source/libdwarf"
    system config_cmd
    system "make"
    ENV['LD_LIBRARY_PATH'] = ENV['LD_LIBRARY_PATH']+":#{prefix}/libdwarf"

    # build dwarfdump
    Dir.chdir prefix+"/source/dwarfdump"
    system config_cmd
    system "make"

    # build dwarfdump2
    Dir.chdir prefix+"/source/dwarfdump2"
    system config_cmd
    system "make"

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
    Dir.chdir prefix+"/source/libdwarf"
    FileUtils.install 'libdwarf.a', install_lib, :mode => 0644
    FileUtils.install 'libdwarf.so', install_lib, :mode => 0755

    # install headers
    FileUtils.install %w{ dwarf.h libdwarf.h }, install_inc, :mode => 0644

    # install executables
    Dir.chdir prefix+"/source/dwarfdump"
    FileUtils.install 'dwarfdump', install_bin, :mode => 0755
    FileUtils.install 'dwarfdump.conf', install_lib, :mode => 0644
    FileUtils.install 'dwarfdump.1', install_man, :mode => 0644
    Dir.chdir prefix+"/source/dwarfdump2"
    FileUtils.install 'dwarfdump', install_bin+"/dwarfdump2", :mode => 0755
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
