BUILD_DIR='build'
SDK_BUILD_VERSION=ENV["SDK_BUILD_VERSION"] || ""

def system_or_exit(cmd, log=nil)
  puts "\033[32m==>\033[0m #{cmd}"
  if log
    logfile = "#{BUILD_DIR}/#{log}"
    system("mkdir -p #{BUILD_DIR.inspect}")
    unless system("#{cmd} 2>&1 > #{logfile.inspect}")
      system("cat #{logfile.inspect}")
      puts ""
      puts ""
      puts "[Failed] #{cmd}"
      puts "         Output is logged to: #{logfile}"
      exit 1
    end
  else
    unless system(cmd)
      puts "[Failed] #{cmd}"
      exit 1
    end
  end
end

class Simulator
  def self.quit
    system("osascript -e 'tell app \"iOS Simulator\" to quit' > /dev/null")
    sleep(1)
  end
end

def xcbuild(cmd)
  Simulator.quit
  unless system_or_exit("xcodebuild -project JKVValue.xcodeproj #{cmd}", "build.txt")
  end
end

desc 'Cleans build directory'
task :clean do
  system_or_exit("rm -rf #{BUILD_DIR.inspect} 2>&1 > '#{BUILD_DIR}/clean.txt' || true")
end

task :deps do
  system_or_exit("carthage build")
end

desc 'Cleans build directory for OS X'
task osx_specs: :deps do
  xcbuild("clean test -scheme JKVValue-OSX -sdk macosx -destination 'platform=OS X' SYMROOT=#{BUILD_DIR.inspect}")
end

desc 'Runs the iOS spec bundle'
task ios_specs: :deps do
  xcbuild("clean test -scheme JKVValue-iOS -sdk iphonesimulator#{SDK_BUILD_VERSION} SYMROOT=#{BUILD_DIR.inspect} -destination 'name=iPhone 6s'")
end

desc 'Runs the tvOS spec bundle'
task tvos_specs: :deps do
  xcbuild("clean test -scheme JKVValue-tvOS -sdk appletvsimulator#{SDK_BUILD_VERSION} SYMROOT=#{BUILD_DIR.inspect} -destination 'name=Apple TV 1080p'")
end

desc 'Runs the cocoapod spec linter'
task :lint do
  system_or_exit('pod lib lint JKVValue.podspec')
end

desc 'Cuts a new release of JKVValue'
task :release, [:version] => [:default] do |t, args|
  system_or_exit("scripts/release #{args[:version]}")
end

task :default => [
  :clean,
  :osx_specs,
  :ios_specs,
  :tvos_specs,
]
desc 'Runs what CI would run'
task :ci => [
  :clean,
  :osx_specs,
  :ios_specs,
  :tvos_specs,
]
