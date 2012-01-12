# spec/spec_helper.rb

current_path = File.expand_path(File.dirname __FILE__)
$LOAD_PATH << current_path.gsub(/vendor[\w\/]+/, "lib")

###############################################################################
# SET UP LOGGING
###############################################################################

require 'debug/file_logger'
require 'debug/logger_service'

include RoundTable::Debug::LoggerService

file_path = "#{Dir.pwd}/log/log_spec.txt"
File.new(file_path, "w+") unless File.exists?(file_path)
File.open(file_path, "w+") { |file| file.truncate(0) }

logger = RoundTable::Debug::FileLogger.new file_path
RoundTable::Debug::LoggerService::StoredLogger.logger = logger

logger.format = "\n\n%m"
logger.info "Running spec_helper..."
logger.format = "%L %m"

###############################################################################
# CUSTOM MATCHERS
###############################################################################

RSpec::Matchers.define :include_matching do |expected|
  match do |actual|
    actual.inject(false) { |memo, obj| memo || obj =~ expected }
  end # match do |actual|
  
  failure_message_for_should do |actual|
    "expected that #{actual} would include an element matching #{expected}"
  end # failure_message_for_should
  
  failure_message_for_should_not do |actual|
    "expected that #{actual} would not include an element matching #{expected}"
  end # failure_message_for_should_not
end # define :include_matching

###############################################################################
# SPEC HELPERS
###############################################################################

require 'events/event_dispatcher'

module RSpec
  module Helpers
    def self.capture_events(subject, event_type = :*)
      ary = Array.new
      subject.add_listener event_type, Proc.new { |evt|
        ary << evt
      } # end listener :*
      yield
      ary
    end # method self.capture_events
  end # module Helpers
end # module RSpec

###############################################################################
# SET UP SPECS
###############################################################################

require 'text_explorer'

module TextExplorer
  module Mock # :nodoc:
  end # module Mock
end # module TextExplorer
