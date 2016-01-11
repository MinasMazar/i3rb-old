require "bundler/gem_tasks"

task :test, [:file] do |t, args|
  all_test_files = FileList.new("test/test_*")
  test_file = "test/test_#{args[:file]}.rb"
  if all_test_files.include? test_file
    system "bundle exec ruby -Itest #{test_file}"
  else
    begin
      puts "Running all tests?? (Return to continue with test, C-c to break"
      $stdin.readline
    rescue Interrupt
      exit(-1)
    end
    all_test_files.each do |f|
      system "bundle exec ruby -Itest #{f}"
    end
  end
end
