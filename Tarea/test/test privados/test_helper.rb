ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"
require "json"
require "database_cleaner/active_record"
require "fileutils"
require "minitest/reporters"
require "rack/test"
require "iic2143_reporter"

Minitest::Reporters.use!(
  Minitest::Reporters::ProgressReporter.new(color: true),
  ENV,
  Minitest.backtrace_filter
)

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean_with(:truncation)

module ActiveSupport
  class TestCase
    # Evita problemas al calcular el puntaje entre procesos paralelos.
    parallelize(workers: 1)

    # No usar fixtures :all: agregaba los registros MyString.
    include FactoryBot::Syntax::Methods
    include Rack::Test::Methods

    @@total_score = 0.0
    @@failed_tests = []
    MAX_SCORE = 6.0

    def app
      Rails.application
    end

    def json_response
      ::JSON.parse(response.body)
    end

    setup do
      DatabaseCleaner.start
    end

    teardown do
      add_score_if_passed
      record_failure_if_needed
    ensure
      DatabaseCleaner.clean
    end

    def self.feedback_message(score)
      score = score.clamp(0.0, MAX_SCORE)

      case score
      when 6.0..MAX_SCORE
        "¡Excelente! Completaste Easy, Medium y Hard 🚀"
      when 5.0..6.0
        "¡Excelente! Completaste Easy y Medium; Hard permite llegar al 7.0 🚀"
      when 4.0...5.0
        "Vas bien, pero todavía faltan requisitos importantes por completar."
      else
        "Revisa los requisitos principales y vuelve a ejecutar los tests."
      end
    end

    private

    def add_score_if_passed
      return unless passed?

      file_path, line_number = method(name).source_location
      test_line = File.readlines(file_path, chomp: true)[line_number - 1]
      points_match = test_line.match(/#.*?(\d+(?:\.\d+)?)\s+puntos?/i)

      @@total_score += points_match[1].to_f if points_match
    rescue StandardError => error
      warn "No se pudo calcular el puntaje de #{name}: #{error.message}"
    end

    def record_failure_if_needed
      return if passed?

      readable_name = name
        .sub(/\Atest_\d+_/, "")
        .tr("_", " ")
        .capitalize

      @@failed_tests << readable_name
    end

    Minitest.after_run do
      score = ActiveSupport::TestCase.class_variable_get(:@@total_score)
      failed_tests = ActiveSupport::TestCase.class_variable_get(:@@failed_tests)

      puts "\nPuntaje total: #{score.round(2)}/#{ActiveSupport::TestCase::MAX_SCORE}"

      report = IIC2143Reporter::Reporter.new(
        score,
        ActiveSupport::TestCase::MAX_SCORE,
        failed_tests,
        ActiveSupport::TestCase.feedback_message(score)
      )

      report_path = Rails.root.join("public", "test_report.html")
      FileUtils.mkdir_p(report_path.dirname)
      report.generate(report_path)
    end
  end
end
