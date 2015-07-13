class ThrustFormula < Formula
  homepage "https://github.com/thrust/thrust"
  url "https://github.com/thrust/thrust.git"

  concern for_version("dev") do
    included do
      url "none"

      def install
        module_list

        system "rm -rf thrust"
        system "git clone https://github.com/thrust/thrust.git"
        system "cd thrust; git checkout origin/master"
      end
    end
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
       puts stderr "<%= @package.name %> <%= @package.version %>"
       puts stderr ""
    }
    # One line description
    module-whatis "<%= @package.name %> <%= @package.version %>"

    setenv THRUST_INCLUDE <%= @package.prefix %>/source

  MODULEFILE
end
