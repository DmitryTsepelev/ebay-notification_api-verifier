require "spec_helper"

RSpec.describe Ebay::NotificationApi::Verifier do
  let(:private_key) { OpenSSL::PKey::EC.new("secp256k1").generate_key }

  let(:public_key) do
    OpenSSL::PKey::EC.new(private_key.public_key.group).tap do |key|
      key.public_key = private_key.public_key
    end
  end

  let(:message) { JSON.parse(File.read("spec/fixtures/message.json")) }

  let(:signed_payload) { message.to_json }

  let(:signature) do
    digest = OpenSSL::Digest.new("SHA1")
    signature = private_key.sign(digest, signed_payload)
    Base64.encode64(signature).delete("\n")
  end

  let(:ebay_signature_header) do
    Base64.encode64({
      "alg" => "ecdsa", "kid" => "kid", "signature" => signature, "digest" => "SHA1"
    }.to_json)
  end

  let(:public_key_response) do
    {"key" => public_key.to_pem.delete("\n"), "algorithm" => "ECDSA", "digest" => "SHA1"}
  end

  before do
    allow(HTTParty).to receive(:get).and_return(public_key_response)
    described_class.application_token_proc = proc { "token" }
  end

  after do
    described_class.remove_instance_variable(:@application_token_proc)
  end

  subject { described_class.valid_message?(message, ebay_signature_header) }

  it { is_expected.to be(true) }

  context "when different message is signed" do
    let(:signed_payload) { {}.to_json }

    it { is_expected.to be(false) }
  end
end
