
TEST_PROJ_PATH="MaVec.xcodeproj"
TEST_SCHEME="MaVec-Demo"

namespace :install do

  task :tools do
    # don't care if this fails on travis
    sh("brew update") rescue nil
    sh("brew upgrade xctool") rescue nil
  end

end

task :install do
  Rake::Task['install:tools'].invoke
end

#
# Test
#

task :test do
  sh("xctool -workspace '#{TEST_PROJ_PATH}' -scheme '#{TEST_SCHEME}' -sdk iphonesimulator build test") rescue nil
  exit $?.exitstatus
end

#
# Analyze
#

task :analyze do
  sh("xctool -workspace '#{TEST_PROJ_PATH}' -scheme '#{TEST_SCHEME}' -sdk iphonesimulator analyze -failOnWarnings") rescue nil
  exit $?.exitstatus
end

#
# Clean
#

namespace :clean do
  
  task :tests do
    sh("xctool -project '#{TEST_PROJ_PATH}' -scheme '#{TEST_SCHEME}' -sdk iphonesimulator clean") rescue nil
  end
    
end

task :clean do
  Rake::Task['clean:tests'].invoke
end


#
# Utils
#

task :usage do
  puts "Usage:"
  puts "  rake install       -- install all dependencies (xctool)"
  puts "  rake install:tools -- install build tool dependencies"
  puts "  rake test          -- run unit tests"
  puts "  rake clean         -- clean everything"
  puts "  rake clean:tests   -- clean the test project build artifacts"
  puts "  rake usage         -- print this message"
end

#
# Default
#

task :default => 'usage'
