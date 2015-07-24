require 'rbconfig'
require 'java'

##########################################################################################
# Configuration. Remove setting before publishing Gem.
##########################################################################################

# set to true if development environment
$DVLP = true

# Set development dependency: those are gems that are also in development and thus not
# installed in the gem directory.  Need a way of accessing them.  Note that we need to
# add a dependency to the gem itself.
$DVLP_DEPEND=["jcsv"]

# Set dependencies from other local gems provided in the vendor directory. 
$VENDOR_DEPEND=[]

##########################################################################################

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
  else 'default'
  end

#---------------------------------------------------------------------------------------
# Add path to load path
#---------------------------------------------------------------------------------------

def mklib(path, home_path = true)
  
  if (home_path)
    lib = path + "/lib"
  else
    lib = path
  end
  
  $LOAD_PATH.insert(0, lib)

end

##########################################################################################
# Prepare environment to work inside Cygwin
##########################################################################################

if @platform == 'windows-cygwin'
  
  #---------------------------------------------------------------------------------------
  # Return the cygpath of a path
  #---------------------------------------------------------------------------------------
  
  def set_path(path)
    `cygpath -a -p -m #{path}`.tr("\n", "")
  end
  
else
  
  #---------------------------------------------------------------------------------------
  # Return  the path
  #---------------------------------------------------------------------------------------
  
  def set_path(path)
    path
  end
  
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

#---------------------------------------------------------------------------------------
# Set dependencies
#---------------------------------------------------------------------------------------

def depend(name)
  
  dependency_dir = Jcsv.project_dir + "/" + name
  mklib(dependency_dir)
  
end

$VENDOR_DEPEND.each do |dep|
  vendor_depend(dep)
end if $VENDOR_DEPEND

##########################################################################################
# Config gem
##########################################################################################

if ($DVLP == true)

  #---------------------------------------------------------------------------------------
  # Set development dependencies
  #---------------------------------------------------------------------------------------
  
  def depend(name)
    dependency_dir = Jcsv.project_dir + "/" + name
    mklib(dependency_dir)
  end

  # Add dependencies here
  # depend(<other_gems>)
  $DVLP_DEPEND.each do |dep|
    depend(dep)
  end if $DVLP_DEPEND

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

end

##########################################################################################
# Load necessary jar files
##########################################################################################

#Dir["#{File.dirname(__FILE__)}/vendor/*.jar"].each do |jar|
Dir["#{Jcsv.vendor_dir}/*.jar"].each do |jar|
  require jar
end

Dir["#{Jcsv.target_dir}/*.jar"].each do |jar|
  require jar
end
