class CblasFormula < Formula
  homepage "http://www.netlib.org/blas/"
  url      "http://www.netlib.org/blas/blast-forum/cblas.tgz"

  version "20110120"

  module_commands do
    pe = "PE-"
    pe = "PrgEnv-" if cray_system?

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

    commands << "load acml"
    commands
  end

  def install
    module_list

    FileUtils.rm_f "Makefile.in"

    acml_prefix = module_environment_variable("acml", "ACML_BASE_DIR")

    patch <<-EOF.strip_heredoc
      diff --git a/Makefile.in b/Makefile.in
      new file mode 100644
      index 0000000..1235d4b
      --- /dev/null
      +++ b/Makefile.in
      @@ -0,0 +1,12 @@
      +SHELL = /bin/sh
      +PLAT = LINUX
      +BLLIB = #{acml_prefix}/gfortran64/lib/libacml.a
      +CBLIB = #{prefix}/lib/libcblas.a
      +CC = gcc
      +FC = gfortran
      +LOADER = $(FC)
      +CFLAGS = -O3 -DADD_
      +FFLAGS = -O3
      +ARCH = ar
      +ARCHFLAGS = r
      +RANLIB = ranlib
    EOF

    system "cat Makefile.in"
    system "make clean"
    FileUtils.mkdir_p "#{prefix}/lib"
    system "make all"
    FileUtils.cp_r "include", prefix
  end
end
