root_folder = File.expand_path("#{File.dirname(__FILE__)}/..")
require "buildscripts/project_details"

# The folders array denoting where to place build artifacts

folders = {
  :root => root_folder,
  :src => "src",
  :build => "build",
  :binaries => "placeholder - environment.rb sets this depending on target",
  :tools => "tools",
  :tests => "build/tests",
  :nuget => "build/nuget",
  :nuspec => "build/nuspec"
}

FOLDERS = folders.merge({

  :autotx => {
      :test_dir => 'IQT Logirel Test.Tests',
      :nuspec => "#{File.join(folders[:nuspec], PROJECTS[:autotx][:nuget_key])}",
      :out => 'placeholder - environment.rb will sets this',
      :test_out => 'placeholder - environment.rb sets this'
  },
  
})

FILES = {
  :sln => "src/iqt-logirel-tst.sln",
  
  :autotx => {
    :nuspec => File.join(FOLDERS[:autotx][:nuspec], "#{PROJECTS[:autotx][:nuget_key]}.nuspec")
  },
  
}

COMMANDS = {
  :nuget => File.join(FOLDERS[:tools], "NuGet.exe"),
  :ilmerge => File.join(FOLDERS[:tools], "ILMerge.exe")
  # nunit etc
}

URIS = {
  :nuget_offical => "http://packages.nuget.org/v1/",
  :nuget_symbolsource => "http://nuget.gw.symbolsource.org/Public/Nuget"
}