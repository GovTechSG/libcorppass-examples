# Load all Gemfiles in immediate subdirectories
Dir.glob(File.join(File.dirname(__FILE__), '**', 'Gemfile')) do |bundle|
  next if bundle == File.join(File.dirname(__FILE__), 'Gemfile')
  instance_eval(Bundler.read_file(bundle), bundle)
end
