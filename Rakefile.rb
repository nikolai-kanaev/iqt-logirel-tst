require "rubygems"
require "bundler"
Bundler.setup
$: << './'

require 'albacore'
require 'rake/clean'
require 'semver'

require 'buildscripts/utils'
require 'buildscripts/paths'
require 'buildscripts/project_details'
require 'buildscripts/environment'

# to get the current version of the project, type 'SemVer.find.to_s' in this rake file.

desc 'generate the shared assembly info'
assemblyinfo :assemblyinfo => ["env:release"] do |asm|
  data = commit_data() #hash + date
  asm.product_name = asm.title = PROJECTS[:autotx][:title]
  asm.description = PROJECTS[:autotx][:description] + " #{data[0]} - #{data[1]}"
  asm.company_name = PROJECTS[:autotx][:company]
  # This is the version number used by framework during build and at runtime to locate, link and load the assemblies. When you add reference to any assembly in your project, it is this version number which gets embedded.
  asm.version = BUILD_VERSION
  # Assembly File Version : This is the version number given to file as in file system. It is displayed by Windows Explorer. Its never used by .NET framework or runtime for referencing.
  asm.file_version = BUILD_VERSION
  asm.custom_attributes :AssemblyInformationalVersion => "#{BUILD_VERSION}", # disposed as product version in explorer
    :CLSCompliantAttribute => false,
    :AssemblyConfiguration => "#{CONFIGURATION}",
    :Guid => PROJECTS[:autotx][:guid]
  asm.com_visible = false
  asm.copyright = PROJECTS[:autotx][:copyright]
  asm.output_file = File.join(FOLDERS[:src], 'SharedAssemblyInfo.cs')
  asm.namespaces = "System", "System.Reflection", "System.Runtime.InteropServices", "System.Security"
end


desc "build sln file"
msbuild :msbuild do |msb|
  msb.solution   = FILES[:sln]
  msb.properties :Configuration => CONFIGURATION
  msb.targets    :Clean, :Build
end


task :autotx_output => [:msbuild] do
  target = File.join(FOLDERS[:binaries], PROJECTS[:autotx][:id])
  copy_files FOLDERS[:autotx][:out], "*.{xml,dll,pdb,config}", target
  CLEAN.include(target)
end

task :output => [:autotx_output]
task :nuspecs => [:autotx_nuspec]

desc "Create a nuspec for 'IQT Logirel Test'"
nuspec :autotx_nuspec do |nuspec|
  nuspec.id = "#{PROJECTS[:autotx][:nuget_key]}"
  nuspec.version = BUILD_VERSION
  nuspec.authors = "#{PROJECTS[:autotx][:authors]}"
  nuspec.description = "#{PROJECTS[:autotx][:description]}"
  nuspec.title = "#{PROJECTS[:autotx][:title]}"
  # nuspec.projectUrl = 'http://github.com/haf' # TODO: Set this for nuget generation
  nuspec.language = "en-US"
  nuspec.licenseUrl = "http://www.apache.org/licenses/LICENSE-2.0" # TODO: set this for nuget generation
  nuspec.requireLicenseAcceptance = "false"
  
  nuspec.output_file = FILES[:autotx][:nuspec]
  nuspec_copy(:autotx, "#{PROJECTS[:autotx][:id]}.{dll,pdb,xml}")
end

task :nugets => [:"env:release", :nuspecs, :autotx_nuget]

desc "nuget pack 'IQT Logirel Test'"
nugetpack :autotx_nuget do |nuget|
   nuget.command     = "#{COMMANDS[:nuget]}"
   nuget.nuspec      = "#{FILES[:autotx][:nuspec]}"
   # nuget.base_folder = "."
   nuget.output      = "#{FOLDERS[:nuget]}"
end

task :publish => [:"env:release", :autotx_nuget_push]

desc "publishes (pushes) the nuget package 'IQT Logirel Test'"
nugetpush :autotx_nuget_push do |nuget|
  nuget.command = "#{COMMANDS[:nuget]}"
  nuget.package = "#{File.join(FOLDERS[:nuget], PROJECTS[:autotx][:nuget_key] + "." + BUILD_VERSION + '.nupkg')}"
# nuget.apikey = "...."
  nuget.source = URIS[:nuget_offical]
  nuget.create_only = false
end

task :default  => ["env:release", "assemblyinfo", "msbuild", "output"]