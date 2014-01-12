Dir.glob('./Externals/thrust/lib/tasks/*.rake').each { |r| import r }

def system_or_exit(cmd)
  puts "Running: #{cmd}"
  unless system(cmd)
    exit 1
  end
end

task :lint do
  system_or_exit('pod spec lint')
end

task :default => [:clean, :specs_6, :osxspecs_108]
task :ci => [:clean, :specs_6, :osxspecs_108, :specs_7, :osxspecs_109, :lint]
