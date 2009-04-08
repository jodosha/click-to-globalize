require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'ftools'
require 'test/javascript/lib/jstest'

# rails_root = File.expand_path(File.readlink(File.dirname(__FILE__)) + "/../../..")
rails_root = "/Users/luca/demo/test_click"

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the click-to-globalize plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the click-to-globalize plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Click to Globalize'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Test Click To Globalize.'
task :test => ['click:test:all']

namespace :test do
  desc 'Test both ruby and javascript code.'
  task :all => [:ruby, :js]

  desc 'Test ruby code.'
  Rake::TestTask.new(:ruby) do |t|
    t.libs << "lib"
    t.libs << "test/test_helper"
    t.pattern = "test/**/*_test.rb"
    t.verbose = true
  end

  desc "Runs all the JavaScript unit tests and collects the results"
  ClickToGlobalizeJavaScriptTestTask.new(:js) do |t|
    tests_to_run     = ENV['TESTS']    && ENV['TESTS'].split(',')
    browsers_to_test = ENV['BROWSERS'] && ENV['BROWSERS'].split(',')

    t.load_tests(tests_to_run)
    t.prepare_tests
    t.mount_paths

    %w( safari firefox ie konqueror opera ).each do |browser|
      t.browser(browser.to_sym) unless browsers_to_test && !browsers_to_test.include?(browser)
    end
  end
end

desc 'Show the diffs for each file, camparing the app files with the plugin ones.'
task :diff do
  %w{ javascripts/click_to_globalize.js stylesheets/click_to_globalize.css }.each do |file|
    puts "\n\n#{file}\n#{'*' * 80}\n"
    `diff #{rails_root}/public/#{file} assets/#{file}`
  end
end

desc 'Prepare the folder plugin, copying files from the app, here.'
task :prepare do
  sources = Dir["#{rails_root}/public/**/click_to_globalize.*"]
  FileUtils.cp_r sources, "assets/"
end
