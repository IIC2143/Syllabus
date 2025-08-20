# test/test_helper.rb
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "database_cleaner/active_record"
require "rack/test"
require "minitest/reporters"
require "iic2143_reporter"

Minitest::Reporters.use!(
  Minitest::Reporters::ProgressReporter.new(color: true),
  ENV,
  Minitest.backtrace_filter
)

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
    include FactoryBot::Syntax::Methods
    include Rack::Test::Methods

    DatabaseCleaner.strategy = :truncation

    @@total_score = 0
    MAX_SCORE = 6
    @@failed_tests = []

    def app
      Rails.application
    end

    setup do
      DatabaseCleaner.start
    end

    teardown do
      DatabaseCleaner.clean
      add_score_if_passed
      record_failure_if_needed
    end

    def json_response
      ActiveSupport::JSON.decode(response.body)
    end

    def add_score(points)
      @@total_score += points if passed?
    end

    def self.feedback_message(score)
      score = [[score, 0].max, 6.0].min
      case score
      when 5.5..6.0 then "¡Excelente! tienes un puntaje sobre 5.5 🚀"
      when 4.0..5.4 then "Buen trabajo, pero revisa algunos casos 🧐. Aún quedan bastantes aspectos por mejorar"
      else "Debes revisar los requisitos principales 📚. No se ha superado el 4.0"
      end
    end

    private

    def add_score_if_passed
      return unless passed?
      test_method = self.method(name)
      file_path, line_number = test_method.source_location
      test_line = File.readlines(file_path)[line_number - 1]
      points_match = test_line.match(/# (\d+\.\d+) puntos?/)
      points = points_match ? points_match[1].to_f : 0.0
      
      add_score(points)
    rescue => e
      puts "⚠️ Error al calcular puntos para #{name}: #{e.message}"
    end

    def record_failure_if_needed
      return if passed?
      test_name = self.name.gsub(/test_\d+_/, '').tr('_', ' ').capitalize
      @@failed_tests << test_name
    end

    Minitest.after_run do
      require 'iic2143_reporter'
      
      report = IIC2143Reporter::Reporter.new(
        @@total_score,
        ActiveSupport::TestCase::MAX_SCORE,
        ActiveSupport::TestCase.class_variable_get(:@@failed_tests),
        ActiveSupport::TestCase.feedback_message(@@total_score)
      )
      
      report.generate(Rails.root.join("public", "test_report.html"))
    end
  end
end