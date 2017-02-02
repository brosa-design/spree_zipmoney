module Spree
  class ZipmoneyController < Spree::BaseController

    skip_before_action :verify_authenticity_token, only: :webhook
    before_action :load_order, except: :webhook

    def webhook
      @request_json = JSON.parse(request.raw_post) rescue {}
      if @request_json["Type"] == "SubscriptionConfirmation"
        call_subscribe_url
      else
        manage_notification
      end
      render nothing: true
    end

    def success
      complete_order(Spree.t(:order_processed_successfully))
    end

    def error
      flash[:error] = Spree.t(:error_processing_payment, scope: [:zipmoney])
      redirect_to checkout_state_path(@order.state)
    end

    def decline
      flash[:error] = Spree.t(:payment_declined, scope: [:zipmoney])
      redirect_to checkout_state_path(@order.state)
    end

    def refer
      complete_order(Spree.t(:payment_under_review, scope: [:zipmoney]))
    end

    def cancel
      flash[:error] = Spree.t(:payment_cancelled, scope: [:zipmoney])
      redirect_to checkout_state_path(@order.state)
    end

    private

    def complete_order(flash_message)
      unless @order.next
        flash[:error] = @order.errors.full_messages.join("\n")
        redirect_to(checkout_state_path(@order.state)) && return
      end

      if @order.completed?
        @current_order = nil
        flash[:notice] = flash_message
        flash['order_completed'] = true
        redirect_to completion_route
      else
        redirect_to checkout_state_path(@order.state)
      end
    end

    def load_order
      @order = Spree::Order.incomplete.includes(:adjustments, line_items: [variant: [:images, :option_values, :product]]).lock(true).find_by(number: params[:id])
      redirect_to(spree.cart_path) && return unless @order
    end

    def completion_route
      spree.order_path(@order)
    end

    def call_subscribe_url
      HTTParty.get(@request_json["SubscribeURL"])
    end

    def manage_notification
      notification_json = JSON.parse(@request_json["Message"])
      transaction_id = notification_json["response"]["txn_id"]
      source = Spree::Zipmoney.find_by(transaction_id: transaction_id)
      case @request_json["Subject"]
      when "authorise_succeeded"
        transaction = source.transactions.find_by(action: AUTHORISE_ACTION)
        transaction.update!(success: true)
      when "authorise_failed"
        transaction = source.transactions.find_by(action: AUTHORISE_ACTION)
        transaction.update!(success: false)
      when "cancel_succeeded"
        transaction = source.transactions.find_by(action: VOID_ACTION)
        transaction.update!(success: true)
      when "cancel_failed"
        transaction = source.transactions.find_by(action: VOID_ACTION)
        transaction.update!(success: false)
      when "charge_succeeded", "capture_succeeded"
        transaction = source.transactions.find_by(action: CAPTURE_ACTION)
        transaction.update!(success: true)
      when "charge_failed", "capture_failed"
        transaction = source.transactions.find_by(action: CAPTURE_ACTION)
        transaction.update!(success: false)
      end
    end
  end
end
