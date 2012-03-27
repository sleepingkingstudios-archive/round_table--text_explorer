# Rakefile

task :default => [ :test ]

task :open, :path do |task, args|
  args.path.gsub!(/\.rb/,'')
  system "mate lib/text_explorer/#{args.path}.rb spec/#{args.path}_spec.rb"
end # task :open

task :test, :path do |task, args|
  system "rspec spec/#{args.path} --colour"
end # task :test
