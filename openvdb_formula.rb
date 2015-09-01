class OpenvdbFormula < Formula
  homepage "www.openvdb.org"
  url "http://www.openvdb.org/download/openvdb_3_0_0_library.zip"

  #-----------------------------------------------------
  # Commnads to have the correct module environment.   -
  #                                                    -
  #-----------------------------------------------------
  module_commands do
  [
      "unload PE-pgi PE-intel PE-gnu",
      "load PE-gnu",
      "load boost",
      "load openexr",
      "load ilmbase",
      "load tbb"
  ] end

  def install
    module_list

    #-----------------------------------------------------
    # Commands to build the library.                     -
    #                                                    -
    #-----------------------------------------------------
    boost_root = module_environment_variable("boost", "BOOST_ROOT")
    exr_path = module_environment_variable("openexr", "EXR_PATH")
    ilm_prefix = module_environment_variable("ilmbase", "ILM_PREFIX")
    tbb_path = module_environment_variable("tbb", "TBB_PATH")
    tbb_lib_path = module_environment_variable("tbb", "TBB_LIB_PATH")

    system "module show tbb"
    system "module show boost"
    system "mkdir #{prefix}/openvdb; cp -r #{prefix}/source/* #{prefix}/openvdb"
    system "cd #{prefix}/openvdb; make DESTDIR=#{prefix} CPLUS_INCLUDE_PATH=#{ilm_prefix}/include/OpenEXR:$CPLUS_INCLUDE_PATH EXR_LIB='-lIlmImf-2_2' BOOST_INCL_DIR=#{boost_root}/include BOOST_LIB_DIR=#{boost_root}/lib EXR_LIB_DIR=#{exr_path}/lib EXR_INCL_DIR=#{exr_path}/include ILMBASE_INCL_DIR=#{ilm_prefix}/include ILMBASE_LIB='-lIlmThread-2_2 -lIex-2_2 -lImath-2_2' ILMBASE_LIB_DIR=#{ilm_prefix}/lib TBB_LIB_DIR=#{tbb_lib_path} TBB_INCL_DIR=#{tbb_path}/include CONCURRENT_MALLOC_LIB='-ltbbmalloc' PYTHON_VERSION='' CPPUNIT_INCL_DIR='' LOG4CPLUS_INCL_DIR='' GLFW_INCL_DIR='' install"
  end 

  #-----------------------------------------------------
  # Template for module file.                          -
  #                                                    -
  #-----------------------------------------------------
  modulefile <<-EOF.strip_heredoc
      #%Module
      proc ModulesHelp { } {
        puts stderr "<%= @package.name %> <%= @package.version %>"
        puts stderr "Note that this software is untested and may not work properly. "
      }
      module-whatis "<%= @package.name %> <%= @package.version %>"

      set PREFIX <%= @package.prefix %>

      setenv OPENVDB_DIR $PREFIX
      prepend-path PATH $PREFIX/bin
      prepend-path LD_LIBRARY_PATH $PREFIX/lib
      prepend-path CPATH $PREFIX/include
      prepend-path CPLUS_INCLUDE_PATH $PREFIX/include
      prepend-path C_INCLUDE_PATH $PREFIX/include
      prepend-path OPENVDB_INCLUDE -I$PREFIX/include
      prepend-path OPENVDB_LIB -L$PREFIX/lib/
      prepend-path PKG_CONFIG_PATH $PREFIX/lib/pkgconfig
  EOF
end
