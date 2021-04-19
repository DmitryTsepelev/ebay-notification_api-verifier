require "httparty"

module Ebay
  module NotificationApi
    module Verifier
      class MessageValidator
        class WrongAlgorithm < StandardError; end

        def initialize(message, signature_header)
          @signature_header = signature_header
          @message = message
        end

        def valid_message?
          verifier = OpenSSL::PKey::EC.new(format_key(public_key_response["key"]))
          signature_base64 = Base64.decode64(signature_json["signature"])
          verifier.verify(OpenSSL::Digest.new(DIGEST), signature_base64, @message.to_json)
        end

        private

        PUBLIC_KEY_ENDPOINT = "https://api.ebay.com/commerce/notification/v1/public_key/"
        ALGORITHM = "ECDSA"
        DIGEST = "SHA1"

        def public_key_response
          @public_key_response ||=
            begin
              token = Ebay::NotificationApi::Verifier.application_token
              headers = {"Authorization" => "Bearer #{token}"}
              public_key_url = "#{PUBLIC_KEY_ENDPOINT}#{signature_json["kid"]}"

              HTTParty.get(public_key_url, headers: headers).tap do |response|
                next if response["algorithm"] == ALGORITHM && response["digest"] == DIGEST
                raise WrongAlgorithm
              end
            end
        end

        KEY_PATTERN_START = "-----BEGIN PUBLIC KEY-----"
        KEY_PATTERN_END = "-----END PUBLIC KEY-----"

        def format_key(key)
          key.sub(KEY_PATTERN_START, "#{KEY_PATTERN_START}\n")
            .sub(KEY_PATTERN_END, "\n#{KEY_PATTERN_END}")
        end

        def signature_json
          @signature_json ||= JSON.parse(Base64.decode64(@signature_header))
        end
      end
    end
  end
end
