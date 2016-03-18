source 'https://rubygems.org'

group :development, :test do
  gem 'rubocop'
end

# Load all Gemfiles in immediate subdirectories
Dir.glob(File.join(File.dirname(__FILE__), 'examples', '**', 'Gemfile')) do |bundle|
  next if bundle == File.join(File.dirname(__FILE__), 'Gemfile')
  instance_eval(Bundler.read_file(bundle), bundle)
end
