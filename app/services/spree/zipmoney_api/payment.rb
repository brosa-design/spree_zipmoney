module Spree
  module ZipmoneyApi
    class Payment
      include HTTParty

      attr_reader :order, :payment, :zipmoney_source, :options

      def initialize(zipmoney_source, options = {})
        @zipmoney_source = zipmoney_source
        @order = zipmoney_source.payment.order
        @options = options
      end

      def capture
        @object = ZipMoney::Capture.new
        build_capture_params
        invoke_api
      end

      def cancel
        @object = ZipMoney::Cancel.new
        build_cancel_params
        invoke_api
      end

      def invoke_api
        @response = @object.do
        unless @response.isSuccess
          zipmoney_source.errors.add(:base, @response.getError)
        end
        @response
      end

      def build_capture_params
        build_generic_params
        build_order_params
      end

      def build_cancel_params
        build_generic_params
        build_order_params
      end

      def success?
        @response.try(:isSuccess)
      end

      private
        def build_generic_params
          @object.params.txn_id = zipmoney_source.transaction_id
          @object.params.order_id = order.number
        end

        def build_order_params
          @object.params.order.id = order.number
          @object.params.order.tax = ("%.2f" % order.additional_tax_total).to_f
          @object.params.order.shipping_value = ("%.2f" % order.shipment_total).to_f
          @object.params.order.total = ("%.2f" % order.total).to_f
        end
    end
  end
end
