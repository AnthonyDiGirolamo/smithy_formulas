class BoostFormula < Formula
  homepage "http://www.boost.org/"
  url      "http://downloads.sourceforge.net/project/boost/boost/1.54.0/boost_1_54_0.tar.bz2"
  sha256   "047e927de336af106a24bceba30069980c191529fd76b8dff8eb9a328b48ae1d"

  depends_on [ "bzip2" ]

  module_commands do
    m = [ "unload PrgEnv-gnu PrgEnv-pgi PrgEnv-cray PrgEnv-intel" ]
    case build_name
    when /gnu/
      m << "load PrgEnv-gnu"
    when /pgi/
      m << "load PrgEnv-pgi"
    when /intel/
      m << "load PrgEnv-intel"
    end
  end

  def install
    module_list

    case build_name
    when /gnu/
      toolset="gcc"

      File.open("tools/build/v2/site-config.jam", "w+") do |f|
        f.write <<-EOF.strip_heredoc
          import os ;
          local CRAY_MPICH2_DIR = [ os.environ CRAY_MPICH2_DIR ] ;
          using gcc
            : 4.8.1
            : CC
            : <compileflags>-I#{bzip2.prefix}/include
              <compileflags>-I$(CRAY_MPICH2_DIR)/include
              <linkflags>-L$(CRAY_MPICH2_DIR)/lib
          ;
          using mpi
            : CC
            : <find-shared-library>mpich
            : aprun -n
          ;
        EOF
      end

    when /pgi/
      toolset="pgi"

      # # Boost Ticket: https://svn.boost.org/trac/boost/ticket/8333
      # patch <<-EOF.strip_heredoc
      #   diff --git a/boost/math/special_functions/sinc.hpp b/boost/math/special_functions/sinc.hpp
      #   index ffb19d8..8d2a8a6 100644
      #   --- a/boost/math/special_functions/sinc.hpp
      #   +++ b/boost/math/special_functions/sinc.hpp
      #   @@ -52,16 +52,7 @@ namespace boost
      #            template<typename T>
      #            inline T    sinc_pi_imp(const T x)
      #            {
      #   -#if defined(BOOST_NO_STDC_NAMESPACE) && !defined(__SUNPRO_CC)
      #   -            using    ::abs;
      #   -            using    ::sin;
      #   -            using    ::sqrt;
      #   -#else    /* BOOST_NO_STDC_NAMESPACE */
      #   -            using    ::std::abs;
      #   -            using    ::std::sin;
      #   -            using    ::std::sqrt;
      #   -#endif    /* BOOST_NO_STDC_NAMESPACE */
      #   -
      #   +BOOST_MATH_STD_USING
      #                // Note: this code is *not* thread safe!
      #                static T const    taylor_0_bound = tools::epsilon<T>();
      #                static T const    taylor_2_bound = sqrt(taylor_0_bound);
      # EOF

      # # Boost Ticket: https://svn.boost.org/trac/boost/ticket/8394
      # patch <<-EOF.strip_heredoc
      #   diff -ur boost_1_53_0/libs/mpi/src/python/py_environment.cpp boost_1_53_0.2/libs/mpi/src/python/py_environment.cpp
      #   --- boost_1_53_0/libs/mpi/src/python/py_environment.cpp 2007-11-25 12:38:02.000000000 -0600
      #   +++ boost_1_53_0.2/libs/mpi/src/python/py_environment.cpp       2013-04-04 10:16:05.000000000 -0500
      #   @@ -31,7 +31,7 @@
      #     */
      #    static environment* env;

      #   -bool mpi_init(list python_argv, bool abort_on_exception)
      #   +bool mpi_init(boost::python::list python_argv, bool abort_on_exception)
      #    {
      #      // If MPI is already initialized, do nothing.
      #      if (environment::initialized())
      #   @@ -79,7 +79,7 @@
      #      if (!environment::initialized()) {
      #        // MPI_Init from sys.argv
      #        object sys = object(handle<>(PyImport_ImportModule("sys")));
      #   -    mpi_init(extract<list>(sys.attr("argv")), true);
      #   +    mpi_init(extract<boost::python::list>(sys.attr("argv")), true);

      #        // Setup MPI_Finalize call when the program exits
      #        object atexit = object(handle<>(PyImport_ImportModule("atexit")));
      # EOF

      File.open("tools/build/v2/site-config.jam", "w+") do |f|
        f.write <<-EOF.strip_heredoc
          import os ;
          local CRAY_MPICH2_DIR = [ os.environ CRAY_MPICH2_DIR ] ;
          using pgi
            : 13.7.0
            : pgCC
            : <compileflags>-I#{bzip2.prefix}/include
              <compileflags>-I$(CRAY_MPICH2_DIR)/include
              <linkflags>-L$(CRAY_MPICH2_DIR)/lib
              <compileflags>-mp
          ;
          using mpi
            : CC
            : <find-shared-library>mpichcxx_pgi
            : aprun -n
          ;
        EOF
      end

    when /intel/
      toolset="intel-linux"

      File.open("tools/build/v2/user-config.jam", "w+") do |f|
        f.write <<-EOF.strip_heredoc
          import os ;
          local CRAY_MPICH2_DIR = [ os.environ CRAY_MPICH2_DIR ] ;
          using intel-linux
            : 13.1.3.192
            : icpc
            : <compileflags>-I#{bzip2.prefix}/include
              <compileflags>-I$(CRAY_MPICH2_DIR)/include
              <linkflags>-L$(CRAY_MPICH2_DIR)/lib
          ;
          using mpi
            : CC
            : <find-shared-library>mpichcxx_intel
            : aprun -n
          ;
        EOF
      end
    end

    system "./bootstrap.sh --with-toolset=#{toolset} --prefix=#{prefix}"

    if build_name.include?("intel")
      # remove redundant using intel-linux definition that bootstrap.sh spits
      # out in the project-config.jam
      contents = File.read("project-config.jam").gsub(/if ! intel-linux in \[ feature.values <toolset> \].*{.*using intel-linux ;.*}/m, '')
      File.open("project-config.jam", "w+") do |f|
        f.write contents
      end
    end

    # system "./b2 toolset=#{toolset} link=static --clean"
    # system "./b2 link=static --user-config=#{prefix}/source/tools/build/v2/user-config.jam --debug-configuration install"
    system "./b2 toolset=#{toolset} link=static --debug-configuration install"
  end

  modulefile <<-MODULEFILE.strip_heredoc
    #%Module
    proc ModulesHelp { } {
      puts stderr "<%= @package.name %> <%= @package.version %>"
    }
    module-whatis "<%= @package.name %> <%= @package.version %>"

    <% if @builds.size > 1 %>
    <%= module_build_list @package, @builds %>

    set PREFIX <%= @package.version_directory %>/$BUILD
    <% else %>
    set PREFIX <%= @package.prefix %>
    <% end %>

    conflict boost

    setenv BOOST_DIR   $PREFIX
    set    BOOST_LIB   "-L$PREFIX/lib"
    set    BOOST_INC   "-I$PREFIX/include"
    set    BOOST_LIBS  "-lboost_date_time -lboost_filesystem -lboost_graph -lboost_graph_parallel -lboost_iostreams -lboost_math_c99 -lboost_math_c99f -lboost_math_c99l -lboost_math_tr1 -lboost_math_tr1f -lboost_math_tr1l -lboost_mpi -lboost_prg_exec_monitor -lboost_program_options -lboost_python -lboost_regex -lboost_serialization -lboost_signals -lboost_system -lboost_test_exec_monitor -lboost_thread -lboost_unit_test_framework -lboost_wave -lboost_wserialization"

    setenv BOOST_LIB   $BOOST_LIB
    setenv BOOST_INC   $BOOST_INC
    setenv BOOST_FLAGS "$BOOST_INC $BOOST_LIB"
    setenv BOOST_CLIB  "$BOOST_INC $BOOST_LIB $BOOST_LIBS"

    prepend-path LD_LIBRARY_PATH $PREFIX/lib
  MODULEFILE
end
