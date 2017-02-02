module Spree
  module ZipmoneyApi
    class Checkout
      include HTTParty

      attr_reader :order, :payment, :zipmoney_source, :options

      def initialize(order, payment, zipmoney_source, options = {})
        @order = order
        @payment = payment
        @zipmoney_source = zipmoney_source
        @options = options
        @object = ZipMoney::Checkout.new
      end

      def perform
        build
        invoke_api
      end

      def invoke_api
        @response = @object.do
        if @response.isSuccess
          redirect_url = JSON.parse(@response._responseBody)["redirect_url"] rescue nil
          transaction_id = JSON.parse(@response._responseBody)["txn_id"] rescue nil
          zipmoney_source.update(redirect_url: redirect_url, transaction_id: transaction_id) if redirect_url || transaction_id
        else
          zipmoney_source.errors.add(:base, @response.getError)
        end
        @response
      end

      def build
        build_generic_params
        build_order_params
        build_line_item_params
        build_address_params(:billing_address)
        build_address_params(:shipping_address)
        build_user_params
      end

      def success?
        @response.try(:isSuccess)
      end

      private
        def build_generic_params
          @object.params.charge = options[:auto_capture]
          @object.params.currency_code = options[:currency]
          @object.params.txn_id = payment.number
          @object.params.cart_url = Spree.railtie_routes_url_helpers.cart_url(host: host_url)
          @object.params.success_url = Spree.railtie_routes_url_helpers.success_zipmoney_url(order, host: host_url)
          @object.params.cancel_url = Spree.railtie_routes_url_helpers.cancel_zipmoney_url(order, host: host_url)
          @object.params.error_url = Spree.railtie_routes_url_helpers.error_zipmoney_url(order, host: host_url)
          @object.params.refer_url = Spree.railtie_routes_url_helpers.refer_zipmoney_url(order, host: host_url)
          @object.params.decline_url = Spree.railtie_routes_url_helpers.decline_zipmoney_url(order, host: host_url)
          @object.params.order_id = order.number
        end

        def build_order_params
          @object.params.order.id = order.number
          @object.params.order.tax = ("%.2f" % order.additional_tax_total).to_f
          @object.params.order.shipping_value = ("%.2f" % order.shipment_total).to_f
          @object.params.order.total = ("%.2f" % order.total).to_f
        end

        def build_line_item_params
          order.line_items.each_with_index do |line_item, index|
            @object.params.order.detail[index] = Struct::Detail.new
            @object.params.order.detail[index].quantity = line_item.quantity
            @object.params.order.detail[index].name = line_item.name
            @object.params.order.detail[index].price = ("%.2f" % line_item.price).to_f
            @object.params.order.detail[index].id = line_item.id
          end
        end

        def build_address_params(address_type)
          @object.params.send(address_type).first_name = order.send(address_type).first_name
          @object.params.send(address_type).last_name = order.send(address_type).last_name
          @object.params.send(address_type).line1 = order.send(address_type).address1
          @object.params.send(address_type).line2 = order.send(address_type).address2
          @object.params.send(address_type).country = order.send(address_type).country.try(:name)
          @object.params.send(address_type).zip = order.send(address_type).zipcode
          @object.params.send(address_type).city = order.send(address_type).city
          @object.params.send(address_type).state = order.send(address_type).state_text
        end

        def build_user_params
          if order.user.present?
            @object.params.consumer.first_name = order.user.firstname
            @object.params.consumer.last_name = order.user.lastname
            @object.params.consumer.phone = order.billing_address.phone
            @object.params.consumer.email = order.user.email
          end
        end

        def host_url
          Spree::Store.current.url
        end
    end
  end
end
