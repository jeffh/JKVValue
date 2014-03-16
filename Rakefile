BUILD_DIR='build'

def system_or_exit(cmd)
  puts "Running: #{cmd}"
  unless system(cmd)
    exit 1
  end
end

task :clean do
  system("rm -rf #{BUILD_DIR.inspect}")
end

task :osx_specs do
  system_or_exit("xcodebuild clean test -scheme JKVValueOSX -destination 'platform=OS X' SYMROOT=#{BUILD_DIR.inspect}")
end

task :specs71 do
  system_or_exit("xcodebuild clean test -scheme JKVValue -sdk iphonesimulator -destination 'name=iPhone Retina (4-inch),OS=7.1' SYMROOT=#{BUILD_DIR.inspect}")
  system_or_exit("xcodebuild test -scheme JKVValue -sdk iphonesimulator -destination 'name=iPhone Retina (4-inch),OS=7.0' SYMROOT=#{BUILD_DIR.inspect}")
end

task :specs70 do
  system_or_exit("xcodebuild test -scheme JKVValue -sdk iphonesimulator -destination 'name=iPhone Retina (4-inch),OS=7.0' SYMROOT=#{BUILD_DIR.inspect}")
end

task :lint do
  system_or_exit('pod spec lint')
end

task :default => [:clean, :osx_specs, :specs71, :specs70]
task :ci => [:clean, :osx_specs, :specs70, :lint]
