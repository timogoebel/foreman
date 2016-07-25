namespace :test do
  desc "Test API"
  Rake::TestTask.new(:api) do |t|
    t.libs << "test"
    t.pattern = 'test/functional/api/**/*_test.rb'
    t.verbose = true
    t.warning = false
  end

  desc "Test lib source"
  Rake::TestTask.new(:lib) do |t|
    t.libs << "test"
    t.pattern = 'test/lib/**/*_test.rb'
    t.verbose = true
    t.warning = false
  end

  desc "Test unit source"
  Rake::TestTask.new(:unit) do |t|
    t.libs << "test"
    t.pattern = 'test/unit/**/*_test.rb'
    t.verbose = true
    t.warning = false
  end
end
