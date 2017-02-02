require 'spec_helper'

describe Spree::ZipmoneyController, type: :controller do
  describe "#success" do
    let(:order) { mock_model Spree::Order }
    let(:orders) { double ActiveRecord::Relation }

    def send_request
      spree_get :success, id: order.id
    end

    before do
      allow(Spree::Order).to receive(:incomplete).and_return(orders)
      allow(orders).to receive(:includes).and_return(orders)
      allow(orders).to receive(:lock).with(true).and_return(orders)
      allow(orders).to receive(:find_by).and_return(order)
      allow(order).to receive(:state).and_return("payment")
    end

    context "when order moved to next state" do
      before do
        allow(order).to receive(:next).and_return(true)
        allow(order).to receive(:completed?).and_return(true)
      end

      describe "expects to receive" do
        it { expect(order).to receive(:next).and_return(true) }
        it { expect(order).to receive(:completed?).and_return(true) }

        after { send_request }
      end

      describe "expects to assign" do
        before { send_request }

        it { expect(assigns[:order]).to eq(order) }
      end

      describe "expects to set flash" do
        before { send_request }

        it { expect(flash[:notice]).to eq(Spree.t(:order_processed_successfully)) }
      end

      describe "expects to redirect" do
        before { send_request }

        it { expect(response).to redirect_to(spree.order_path(order)) }
      end
    end

    context "when order not moved to next state" do
      before do
        allow(order).to receive(:next).and_return(false)
        allow(order).to receive_message_chain(:errors, :full_messages, :join) { "Invalid order" }
      end

      describe "expects to receive" do
        it { expect(order).to receive(:next).and_return(false) }
        it { expect(order).to_not receive(:completed?) }

        after { send_request }
      end

      describe "expects to assign" do
        before { send_request }

        it { expect(assigns[:order]).to eq(order) }
      end

      describe "expects to set flash" do
        before { send_request }

        it { expect(flash[:error]).to eq("Invalid order") }
      end

      describe "expects to redirect" do
        before { send_request }

        it { expect(response).to redirect_to(checkout_state_path(order.state)) }
      end
    end
  end

  describe "#refer" do
    let(:order) { mock_model Spree::Order }
    let(:orders) { double ActiveRecord::Relation }

    def send_request
      spree_get :refer, id: order.id
    end

    before do
      allow(Spree::Order).to receive(:incomplete).and_return(orders)
      allow(orders).to receive(:includes).and_return(orders)
      allow(orders).to receive(:lock).with(true).and_return(orders)
      allow(orders).to receive(:find_by).and_return(order)
      allow(order).to receive(:state).and_return("payment")
    end

    context "when order moved to next state" do
      before do
        allow(order).to receive(:next).and_return(true)
        allow(order).to receive(:completed?).and_return(true)
      end

      describe "expects to receive" do
        it { expect(order).to receive(:next).and_return(true) }
        it { expect(order).to receive(:completed?).and_return(true) }

        after { send_request }
      end

      describe "expects to assign" do
        before { send_request }

        it { expect(assigns[:order]).to eq(order) }
      end

      describe "expects to set flash" do
        before { send_request }

        it { expect(flash[:notice]).to eq(Spree.t(:payment_under_review, scope: [:zipmoney])) }
      end

      describe "expects to redirect" do
        before { send_request }

        it { expect(response).to redirect_to(spree.order_path(order)) }
      end
    end

    context "when order not moved to next state" do
      before do
        allow(order).to receive(:next).and_return(false)
        allow(order).to receive_message_chain(:errors, :full_messages, :join) { "Invalid order" }
      end

      describe "expects to receive" do
        it { expect(order).to receive(:next).and_return(false) }
        it { expect(order).to_not receive(:completed?) }

        after { send_request }
      end

      describe "expects to assign" do
        before { send_request }

        it { expect(assigns[:order]).to eq(order) }
      end

      describe "expects to set flash" do
        before { send_request }

        it { expect(flash[:error]).to eq("Invalid order") }
      end

      describe "expects to redirect" do
        before { send_request }

        it { expect(response).to redirect_to(checkout_state_path(order.state)) }
      end
    end
  end

  describe "#error" do
    let(:order) { mock_model Spree::Order }
    let(:orders) { double ActiveRecord::Relation }

    def send_request
      spree_get :error, id: order.id
    end

    before do
      allow(Spree::Order).to receive(:incomplete).and_return(orders)
      allow(orders).to receive(:includes).and_return(orders)
      allow(orders).to receive(:lock).with(true).and_return(orders)
      allow(orders).to receive(:find_by).and_return(order)
      allow(order).to receive(:state).and_return("payment")
    end

    describe "expects to assign" do
      before { send_request }

      it { expect(assigns[:order]).to eq(order) }
    end

    describe "expects to set flash" do
      before { send_request }

      it { expect(flash[:error]).to eq(Spree.t(:error_processing_payment, scope: [:zipmoney])) }
    end

    describe "expects to redirect" do
      before { send_request }

      it { expect(response).to redirect_to(checkout_state_path(order.state)) }
    end
  end

  describe "#decline" do
    let(:order) { mock_model Spree::Order }
    let(:orders) { double ActiveRecord::Relation }

    def send_request
      spree_get :decline, id: order.id
    end

    before do
      allow(Spree::Order).to receive(:incomplete).and_return(orders)
      allow(orders).to receive(:includes).and_return(orders)
      allow(orders).to receive(:lock).with(true).and_return(orders)
      allow(orders).to receive(:find_by).and_return(order)
      allow(order).to receive(:state).and_return("payment")
    end

    describe "expects to assign" do
      before { send_request }

      it { expect(assigns[:order]).to eq(order) }
    end

    describe "expects to set flash" do
      before { send_request }

      it { expect(flash[:error]).to eq(Spree.t(:payment_declined, scope: [:zipmoney])) }
    end

    describe "expects to redirect" do
      before { send_request }

      it { expect(response).to redirect_to(checkout_state_path(order.state)) }
    end
  end

  describe "#cancel" do
    let(:order) { mock_model Spree::Order }
    let(:orders) { double ActiveRecord::Relation }

    def send_request
      spree_get :cancel, id: order.id
    end

    before do
      allow(Spree::Order).to receive(:incomplete).and_return(orders)
      allow(orders).to receive(:includes).and_return(orders)
      allow(orders).to receive(:lock).with(true).and_return(orders)
      allow(orders).to receive(:find_by).and_return(order)
      allow(order).to receive(:state).and_return("payment")
    end

    describe "expects to assign" do
      before { send_request }

      it { expect(assigns[:order]).to eq(order) }
    end

    describe "expects to set flash" do
      before { send_request }

      it { expect(flash[:error]).to eq(Spree.t(:payment_cancelled, scope: [:zipmoney])) }
    end

    describe "expects to redirect" do
      before { send_request }

      it { expect(response).to redirect_to(checkout_state_path(order.state)) }
    end
  end
end
