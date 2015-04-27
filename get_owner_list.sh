git status -s | ruby -e 'require "etc"; require "pp"; STDIN.readlines.sort.each{|l| fn = l.split(" ").last ; puts "#{Etc.getpwuid(File.stat(fn).uid).gecos}, #{fn}" }' | sort > ~/formula_changes.txt
