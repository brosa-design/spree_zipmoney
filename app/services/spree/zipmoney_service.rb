module Spree
  class ZipmoneyService
    attr_reader :order, :payment, :zipmoney_source, :options

    def initialize(zipmoney_source, options = {})
      @zipmoney_source = zipmoney_source
      @payment = zipmoney_source.payment
      @order = @payment.order
      @options = options
    end

    def checkout
      @checkout_request = Spree::ZipmoneyApi::Checkout.new(order, payment, zipmoney_source, options)
      @checkout_request.perform
      @checkout_request.success?
    end

    def capture
      @payment_request = Spree::ZipmoneyApi::Payment.new(zipmoney_source, options)
      @payment_request.capture
      @payment_request.success?
    end

    def cancel
      @payment_request = Spree::ZipmoneyApi::Payment.new(zipmoney_source, options)
      @payment_request.cancel
      @payment_request.success?
    end
  end
end
