require 'spec_helper'

describe Spree::CheckoutController, type: :controller do
  describe "#checkout_zipmoney_payment" do
    let(:order) { mock_model Spree::Order }
    let(:address) { mock_model Spree::Address }
    let(:user) { mock_model Spree::User }
    let(:payment_method) { mock_model Spree::PaymentMethod }
    let(:orders) { double ActiveRecord::Relation }
    let(:payment) { mock_model Spree::Payment }
    let(:payment_source) { mock_model Spree::Zipmoney }
    let(:payments) { double ActiveRecord::Relation }
    let(:email) { 'spree@example.com' }

    def send_request
      spree_post :update,
        state: :payment,
        order: {
          payments_attributes: [
            {
              payment_method_id: payment_method.id.to_s
            }
          ]
        },
        payment_source: {
          payment_method.id.to_s => {
            email: email
          }
        }
    end

    before do
      allow(controller).to receive(:current_order).with(lock: true).and_return(order)
      allow(controller).to receive(:current_order).and_return(order)
      allow(controller).to receive(:current_currency).and_return("AUD")
      allow(controller).to receive(:check_registration)
      allow(order).to receive(:can_go_to_state?).with("payment").and_return(false)
      allow(order).to receive(:state).and_return("payment")
      allow(order).to receive(:state=).with("payment").and_return(order)
      allow(order).to receive(:completed?).and_return(false)
      allow(order).to receive(:checkout_allowed?).and_return(true)
      allow(order).to receive(:insufficient_stock_lines).and_return(false)
      allow(order).to receive(:has_checkout_step?).and_return(true)
      allow(order).to receive(:bill_address).and_return(address)
      allow(order).to receive(:checkout_steps).and_return(["address", "payment", "completed"])
      allow(order).to receive(:user).and_return(user)
      allow(controller).to receive(:try_spree_current_user).and_return(user)
      allow(order).to receive(:email).and_return('abc@example.com')
      allow(user).to receive(:orders).and_return(orders)
      allow(orders).to receive(:incomplete).and_return(orders)
      allow(orders).to receive(:where).with('id != ?', order.id).and_return([])
    end

    context "when zipmoney payment present in params" do
      before do
        allow(controller).to receive(:zipmoney_payment_method).and_return(payment_method)
        allow(order).to receive(:payments).and_return(payments)
        allow(order).to receive(:outstanding_balance).and_return(10)
        allow(payments).to receive(:zipmoney).and_return(payments)
        allow(payments).to receive(:checkout).and_return(payments)
        allow(payments).to receive(:map)
        allow(payments).to receive(:first).and_return(payment)
        allow(payments).to receive(:create!).and_return(true)
        allow(payment).to receive(:source).and_return(payment_source)
        allow(payment_source).to receive(:checkout).and_return(true)
        allow(payment_source).to receive(:redirect_url).and_return(spree.root_path)
        allow(payment_method).to receive(:auto_capture?).and_return(true)
      end

      describe "expects to receive" do
        it { expect(controller).to receive(:zipmoney_payment_method).and_return(payment_method) }
        it { expect(payment).to receive(:source).and_return(payment_source) }
        it { expect(payment_source).to receive(:checkout).and_return(true) }

        after { send_request }
      end

      describe "expects to redirect" do
        before { send_request }

        it { expect(response).to redirect_to(spree.root_path) }
      end

      context "when payment_source cannot checkout" do
        before do
          allow(payment_source).to receive(:checkout).and_return(false)
          allow(payment_source).to receive_message_chain(:errors, :full_messages, :to_sentence) { "Invalid payment" }
        end

        describe "expects to receive" do
          it { expect(controller).to receive(:zipmoney_payment_method).and_return(payment_method) }
          it { expect(payment).to receive(:source).and_return(payment_source) }
          it { expect(payment_source).to receive(:checkout).and_return(false) }

          after { send_request }
        end

        describe "expects to redirect" do
          before { send_request }

          it { expect(response).to redirect_to(spree.checkout_state_path("payment")) }
        end

        describe "expects to set flash" do
          before { send_request }

          it { expect(flash[:error]).to eq("Invalid payment") }
        end
      end
    end
  end
end
