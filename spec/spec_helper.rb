require 'tmpdir'
require 'vimrunner'

def assert_correct_indenting(string)
  whitespace = string.scan(/^\s*/).first
  string = string.split("\n").map { |line| line.gsub /^#{whitespace}/, '' }.join("\n").strip

  File.open 'test.rb', 'w' do |f|
    f.write string
  end

  VIM.edit 'test.rb'
  VIM.normal 'gg=G'
  VIM.write

  IO.read('test.rb').strip.should eq string
end

RSpec.configure do |config|
  # cd into a temporary directory for every example.
  config.around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        VIM.command("cd #{dir}")
        example.call
      end
    end
  end

  config.before(:suite) do
    VIM = Vimrunner.start
    runtimepath = VIM.echo '&runtimepath'
    VIM.command("set runtimepath=#{File.expand_path('../..', __FILE__)},#{runtimepath}")
  end

  config.after(:suite) do
    VIM.kill
  end
end
