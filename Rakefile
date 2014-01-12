Dir.glob('./Externals/thrust/lib/tasks/*.rake').each { |r| import r }

task :default => [:clean, :specs_6, :osxspecs_108]
task :ci => [:clean, :specs_6, :osxspecs_108, :specs_7, :osxspecs_109]
