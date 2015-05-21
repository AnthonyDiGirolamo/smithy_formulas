class AgFormula < Formula
  homepage "http://geoff.greer.fm/ag/"
  url "http://geoff.greer.fm/ag/releases/the_silver_searcher-0.30.0.tar.gz"

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
    commands << "load automake"
    commands << "load autoconf"
    commands << "load libtool"
    commands
  end

  def install
    ENV["CC"] = "gcc"
    module_list
    system "which gcc"
    system "export ACLOCAL_PATH=/usr/share/aclocal"
    system "./configure CFLAGS=\"-O3\" --prefix=#{prefix}"
    system "make"
    system "make install"

  end

  modulefile <<-MODULEFILE.strip_heredoc
         #%Module
         proc ModulesHelp { } {
          puts stderr "<%= @package.name %> <% @package.version %>"
          puts stderr "<%= @package.name %> - search in code directories"
          puts stderr "A code searching tool similar to ack, with a focus on speed."
         }
         module-whatis "<%= @package.name %> <% @package.version %>"
         set PREFIX <%= @package.prefix %>

         prepend-path PATH            $PREFIX/bin
         prepend-path MANPATH         $PREFIX/share/man
      MODULEFILE
end


