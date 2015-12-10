class Wgrib2Formula < Formula
	homepage "http://www.cpc.ncep.noaa.gov/products/wesley/wgrib2/"
	url "http://www.ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2.tgz"
	md5 "9b72f7f5c58d1c98d5b0d8448287ed6e"

	module_commands do
		commands = ["unload PrgEnv-gnu PrgEnv-pgi PrgEnv-cray PrgEnv-intel"]
		commands << "load PrgEnv-gnu"
		commands
	end

	def install
		system "gmake FC=gfortran CC=gcc"
		# Wgrib2 does not seem to have an install target
		# so copy necessary directories to prefix, deleting
		# the target directory first if it exists
		["bin", "include", "lib", "share"].each do |dir|
			target_dir = File.join(prefix, dir)
			system "rm -rf #{target_dir}"
			system "cp -R #{dir} #{target_dir}"
		end
		system "cp wgrib2/wgrib2 #{prefix}/bin"
	end

	modulefile do
		<<-MODULEFILE.strip_heredoc
		#%Module

		proc ModulesHelp { } {
		   puts stderr "Sets up environment to use netcdf <%= @package.version %>"
		   puts stderr "Usage:   fortrancompiler test.f90 \${NETCDF_FLIB}"
		   puts stderr "    or   ccompiler test.c \${NETCDF_CLIB}"
		}
		module-whatis "Sets up environment to use netcdf <%= @package.version %>"
		set PREFIX <%= @package.prefix %>
		prepend-path PATH $PREFIX/bin
		prepend-path LD_LIBRARY_PATH  $PREFIX/lib
		prepend-path LIBRARY_PATH     $PREFIX/lib
		prepend-path INCLUDE_PATH     $PREFIX/include
		prepend-path MANPATH          $PREFIX/share/man
		MODULEFILE
	end
end
