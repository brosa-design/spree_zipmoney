Spree::CheckoutController.class_eval do
  before_action :checkout_zipmoney_payment, only: [:update]

  private
    def checkout_zipmoney_payment
      if zipmoney_payment_present?
        @order.payments.zipmoney.checkout.map(&:invalidate!)
        create_zipmoney_payment

        # Remove other payment method parameters.
        params[:order].delete(:payments_attributes)
        params.delete(:payment_source)

        zipmoney_source = @order.payments.zipmoney.checkout.first.try(:source)
        if zipmoney_source && zipmoney_source.checkout(@order.outstanding_balance, currency: current_currency, auto_capture: zipmoney_payment_method.auto_capture?)
          redirect_to zipmoney_source.redirect_url and return
        else
          flash[:error] = zipmoney_source.errors.full_messages.to_sentence if zipmoney_source
          redirect_to checkout_state_path(@order.state) and return
        end
      end
    end

    def create_zipmoney_payment
      source_params = params.require(:payment_source).permit![zipmoney_payment_method.id.to_s]
      @order.payments.create!(
        payment_method: zipmoney_payment_method,
        amount: @order.outstanding_balance,
        state: 'checkout',
        source_attributes: source_params
      )
    end

    def zipmoney_payment_present?
      params[:order] && params[:order][:payments_attributes] && params[:order][:payments_attributes].any? { |p| p[:payment_method_id] == zipmoney_payment_method.try(:id).to_s }
    end

    def zipmoney_payment_method
      @zipmoney_payment_method ||= Spree::PaymentMethod.zipmoney.available_on_front_end.first
    end
end
