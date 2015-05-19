class DataspacesFormula < Formula
  homepage "http://www.dataspaces.org/"
  url      "file:///sw/sources/dataspaces/dataspaces-1.5.0.tar.gz"
  sha1     "454b0c853c0708c454ccbf0554ba32024b37316f" 

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
      commands << "load craype-hugepages2M"
    when /intel/
      commands << "load #{pe}intel"
      commands << "swap intel intel/#{$1}" if build_name =~ /intel([\d\.]+)/
    when /cray/
      commands << "load #{pe}cray"
      commands << "swap cce cce/#{$1}" if build_name =~ /cray([\d\.]+)/
    end
    commands << "swap craype-interlagos craype-istanbul" if pe == "PrgEnv-"
    #puts "#{commands}"
    commands 
  end

  def install

    if build_name.include?("cle")
      ENV["CFLAGS"]  = "-fPIC"
      ENV["CC"]  = "cc"
      ENV["CXX"] = "CC"
      ENV["FC"]  = "ftn"
      confopts="--enable-dimes --with-dimes-rdma-buffer-size=1024 --with-max-num-array-dimension=6 --with-gni-ptag=250 --with-gni-cookie=0x5420000"

    elsif build_name.include?("rhel6") or build_name.include?("rhea") or build_name.include?("sith") 
      ENV["CFLAGS"]  = "-fPIC"
      ENV["CC"]  = "mpicc"
      ENV["CXX"] = "mpicxx"
      ENV["FC"]  = "mpif90"
      confopts="--enable-dimes --with-dimes-rdma-buffer-size=1024 --with-max-num-array-dimension=6"
    else
      raise "Unsupported build system (#{build_name})"
    end

    ENV["CFLAGS"]  = "-fPIC"

    module_list

    system "./configure --prefix=#{prefix} #{confopts}"
    system "make"
    system "make install"
  end
end
