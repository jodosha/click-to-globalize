require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'ftools'

namespace :click do
  desc 'Setup Click to Globalize plugin (alias for click:install).'
  task :setup => :install

  desc 'Install Click to Globalize plugin.'
  task :install do
    target = "#{Rails.root}/public/"
    source = Dir["vendor/plugins/click-to-globalize/assets/*"]

    FileUtils.mkdir_p(target) unless File.directory?(target)
    FileUtils.cp_r source, target
  end

  desc 'Uninstall Click to Globalize plugin.'
  task :uninstall do
    targets = Dir["#{Rails.root}/public/**/click_to_globalize.*"]
    FileUtils.rm targets
  end
end
