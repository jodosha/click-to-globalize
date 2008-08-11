# Force Globalize loading.
if Rails::VERSION::STRING.match /^1\.2+/
  load_plugin(File.join(RAILS_ROOT, 'vendor', 'plugins', 'globalize'))
else
  # Specify the plugins loading order: Click To Globalize should be the last one.
  plugins = (Dir["#{config.plugin_paths}/*"] - [ File.dirname(__FILE__) ]).map { |plugin| plugin.split(File::SEPARATOR).last}
  Rails::Initializer.run { |config| config.plugins = plugins }
end

Object.send :include, Globalize
require 'click_to_globalize'

unless RAILS_ENV == 'test'
  # FIXME
  Locale.load_configured_base_language
  raise NoBaseLanguageError if Locale.base_language.blank?
else
  require File.dirname(__FILE__) + '/test/assertions'
end
