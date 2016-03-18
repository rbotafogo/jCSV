require 'rbconfig'
require 'java'

#
# In principle should not be in this file.  The right way of doing this is by executing
# bundler exec, but I don't know how to do this from inside emacs.  So, should comment
# the next line before publishing the GEM.  If not commented, this should be harmless
# anyway.
#

begin
  require 'bundler/setup'
rescue LoadError
end

# the platform
@platform = 
  case RUBY_PLATFORM
  when /mswin/ then 'windows'
  when /mingw/ then 'windows'
  when /bccwin/ then 'windows'
  when /cygwin/ then 'windows-cygwin'
  when /java/
    require 'java' #:nodoc:
    if java.lang.System.getProperty("os.name") =~ /[Ww]indows/
      'windows-java'
    else
      'default-java'
    end
  else
    'default'
  end

#---------------------------------------------------------------------------------------
# Set the project directories
#---------------------------------------------------------------------------------------

class Jcsv

  @home_dir = File.expand_path File.dirname(__FILE__)

  class << self
    attr_reader :home_dir
  end

  @project_dir = Jcsv.home_dir + "/.."
  @doc_dir = Jcsv.home_dir + "/doc"
  @lib_dir = Jcsv.home_dir + "/lib"
  @src_dir = Jcsv.home_dir + "/src"
  @target_dir = Jcsv.home_dir + "/target"
  @test_dir = Jcsv.home_dir + "/test"
  @vendor_dir = Jcsv.home_dir + "/vendor"
  
  class << self
    attr_reader :project_dir
    attr_reader :doc_dir
    attr_reader :lib_dir
    attr_reader :src_dir
    attr_reader :target_dir
    attr_reader :test_dir
    attr_reader :vendor_dir
  end

  @build_dir = Jcsv.src_dir + "/build"

  class << self
    attr_reader :build_dir
  end

  @classes_dir = Jcsv.build_dir + "/classes"

  class << self
    attr_reader :classes_dir
  end

end


#----------------------------------------------------------------------------------------
# If we need to test for coverage
#----------------------------------------------------------------------------------------

if $COVERAGE == 'true'
  
  require 'simplecov'
  
  SimpleCov.start do
    @filters = []
    add_group "Jcsv"
  end
  
end

##########################################################################################
# Load necessary jar files
##########################################################################################

Dir["#{Jcsv.vendor_dir}/*.jar"].each do |jar|
  require jar
end

Dir["#{Jcsv.target_dir}/*.jar"].each do |jar|
  require jar
end
