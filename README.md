# Ebay::NotificationApi::Verifier

The Ruby implementation of [eBay Notification API verification](https://developer.ebay.com/api-docs/commerce/notification/overview.html#use).

In future it might be used for different cases, but for now eBay requires third–party applications that store user data to implement [eBay Marketplace Account Deletion/Closure Notifications Workflow](https://developer.ebay.com/marketplace-account-deletion). When such HTTP request is received, the backend must ensure, that this request is coming from eBay:

```ruby
class EbayAccountDeletionController < ApplicationController
  def account_deletion_notification
    # eBay wants an immediate response, so we should postpone the deletion
    EbayAccountDeletionWorker.perform_async(params, request.headers["x-ebay-signature"])
    head :ok
  end
end

class EbayAccountDeletionWorker
   include Sidekiq::Worker

  def perform(message, signature)
    return unless Ebay::NotificationApi::Verifier.valid_message?(message, signature)

    # delete data
  end
end
```

⚠️ Heads up! Currently eBay supports only ECDSA/SHA1 encryption, and so does the gem. If something different is passed to the Verifier, the Ebay::NotificationApi::Verifier::WrongAlgorithm would be raised. ⚠️

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ebay-notification_api-verifier'
```

Since we have to perform a request to fetch the public key, the ability to get application token should be provided to the verifier. You can pass any callable object:

```ruby
Ebay::NotificationApi::Verifier.application_token_proc = proc { "token" }
Ebay::NotificationApi::Verifier.application_token_proc = Ebay::TokenFetcher.fetch
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dmitrytsepelev/ebay-notification_api-verifier.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

<p align="center">
  <a href="https://evilmartians.com/?utm_source=ebay-notification_api-verifier">
    <img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54">
  </a>
</p>
