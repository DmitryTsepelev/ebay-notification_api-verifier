# frozen_string_literal: true

require_relative "verifier/version"
require_relative "verifier/message_validator"

module Ebay
  module NotificationApi
    module Verifier
      class WrongAlgorithm < StandardError; end

      class << self
        def valid_message?(*args)
          MessageValidator.new(*args).valid_message?
        end

        def application_token_proc=(value)
          unless value.respond_to?(:call)
            raise ArgumentError, "application_token_proc is not a callable object"
          end

          @application_token_proc = value
        end

        def application_token
          raise ArgumentError, "application_token_proc is not configured" unless @application_token_proc

          @application_token_proc.call
        end
      end
    end
  end
end
