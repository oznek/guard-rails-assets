require 'guard'
require 'guard/guard'
require 'rake/dsl_definition'

module Guard
  class RailsAssets < Guard
    def initialize(watchers=[], options={})
      super
      @options = options || {}
    end

    def create_rails_runner
      @rails_runner = RailsRunner.new
    end

    def rails_runner
      @rails_runner ||= create_rails_runner
    end

    def start
      create_rails_runner

      compile_assets if run_for? :start
    end

    def reload
      rails_runner.restart_rails

      compile_assets if run_for? :reload
    end

    def run_all
      compile_assets if run_for? :all
    end

    def run_on_change(paths=[])
      compile_assets if run_for? :change
    end

    def compile_assets
      puts 'Compiling rails assets'
      result = rails_runner.compile_assets

      if result
        Notifier::notify 'Assets compiled'
      else
        Notifier::notify 'see the details in the terminal', :title => "Can't compile assets", :image => :failed
      end
    end

    def run_for? command
      run_on = @options[:run_on]
      run_on = [:start, :change] if not run_on or run_on.to_s.empty?
      run_on = [run_on] unless run_on.respond_to?(:include?)
      run_on.include?(command)
    end
  end
end

require 'guard/rails-assets/rails_runner'