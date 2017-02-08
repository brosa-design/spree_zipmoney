require 'spec_helper'

describe Spree::ZipmoneyController, type: :controller do
  describe "#webhook" do
    let(:subscribe_url) { "http://www.google.com" }

    def send_request
      request.env["RAW_POST_DATA"]  = params.to_json
      spree_post :webhook
    end

    before do
      allow(HTTParty).to receive(:get).with(subscribe_url)
    end

    context "when SubscriptionConfirmation" do
      let(:params) { { "Type" => "SubscriptionConfirmation", "SubscribeURL" => subscribe_url } }

      describe "expects to assign" do
        before { send_request }

        it { expect(assigns[:request_json]).to eq(params) }
      end

      describe "expects to receive" do
        it { expect(HTTParty).to receive(:get).with(subscribe_url) }

        after { send_request }
      end
    end

    context "when Notification" do
      let(:zipmoney_source) { mock_model(Spree::Zipmoney) }
      let(:transactions) { double(ActiveRecord::Relation) }
      let(:transaction) { mock_model(Spree::ZipmoneyTransaction) }

      before do
        allow(Spree::Zipmoney).to receive(:find_by).with(transaction_id: transaction_id).and_return(zipmoney_source)
      end

      context "when authorise_succeeded" do
        let(:transaction_id) { "12345" }
        let(:params) { { "Type" => "Notification", "Subject" => "authorise_succeeded", "Message" => { "response" => { "txn_id" => transaction_id } }.to_json } }

        before do
          allow(zipmoney_source).to receive(:transactions).and_return(transactions)
          allow(transactions).to receive(:find_by).and_return(transaction)
          allow(transaction).to receive(:update!).and_return(true)
        end

        describe "expects to assign" do
          before { send_request }

          it { expect(assigns[:zipmoney_source]).to eq(zipmoney_source) }
        end

        describe "expects to receive" do
          it { expect(zipmoney_source).to receive(:transactions).and_return(transactions) }
          it { expect(transactions).to receive(:find_by).with(action: Spree::Zipmoney::AUTHORIZE_ACTION).and_return(transaction) }
          it { expect(transaction).to receive(:update!).with(success: true).and_return(true) }

          after { send_request }
        end
      end

      context "when authorise_failed" do
        let(:transaction_id) { "12345" }
        let(:params) { { "Type" => "Notification", "Subject" => "authorise_failed", "Message" => { "response" => { "txn_id" => transaction_id } }.to_json } }

        before do
          allow(zipmoney_source).to receive(:transactions).and_return(transactions)
          allow(transactions).to receive(:find_by).and_return(transaction)
          allow(transaction).to receive(:update!).and_return(true)
        end

        describe "expects to assign" do
          before { send_request }

          it { expect(assigns[:zipmoney_source]).to eq(zipmoney_source) }
        end

        describe "expects to receive" do
          it { expect(zipmoney_source).to receive(:transactions).and_return(transactions) }
          it { expect(transactions).to receive(:find_by).with(action: Spree::Zipmoney::AUTHORIZE_ACTION).and_return(transaction) }
          it { expect(transaction).to receive(:update!).with(success: false).and_return(true) }

          after { send_request }
        end
      end

      context "when cancel_succeeded" do
        let(:transaction_id) { "12345" }
        let(:params) { { "Type" => "Notification", "Subject" => "cancel_succeeded", "Message" => { "response" => { "txn_id" => transaction_id } }.to_json } }

        before do
          allow(zipmoney_source).to receive(:transactions).and_return(transactions)
          allow(transactions).to receive(:find_by).and_return(transaction)
          allow(transaction).to receive(:update!).and_return(true)
        end

        describe "expects to assign" do
          before { send_request }

          it { expect(assigns[:zipmoney_source]).to eq(zipmoney_source) }
        end

        describe "expects to receive" do
          it { expect(zipmoney_source).to receive(:transactions).and_return(transactions) }
          it { expect(transactions).to receive(:find_by).with(action: Spree::Zipmoney::VOID_ACTION).and_return(transaction) }
          it { expect(transaction).to receive(:update!).with(success: true).and_return(true) }

          after { send_request }
        end
      end

      context "when cancel_failed" do
        let(:transaction_id) { "12345" }
        let(:params) { { "Type" => "Notification", "Subject" => "cancel_failed", "Message" => { "response" => { "txn_id" => transaction_id } }.to_json } }

        before do
          allow(zipmoney_source).to receive(:transactions).and_return(transactions)
          allow(transactions).to receive(:find_by).and_return(transaction)
          allow(transaction).to receive(:update!).and_return(true)
        end

        describe "expects to assign" do
          before { send_request }

          it { expect(assigns[:zipmoney_source]).to eq(zipmoney_source) }
        end

        describe "expects to receive" do
          it { expect(zipmoney_source).to receive(:transactions).and_return(transactions) }
          it { expect(transactions).to receive(:find_by).with(action: Spree::Zipmoney::VOID_ACTION).and_return(transaction) }
          it { expect(transaction).to receive(:update!).with(success: false).and_return(true) }

          after { send_request }
        end
      end

      context "when charge_succeeded" do
        let(:transaction_id) { "12345" }
        let(:params) { { "Type" => "Notification", "Subject" => "charge_succeeded", "Message" => { "response" => { "txn_id" => transaction_id } }.to_json } }

        before do
          allow(zipmoney_source).to receive(:transactions).and_return(transactions)
          allow(transactions).to receive(:find_by).and_return(transaction)
          allow(transaction).to receive(:update!).and_return(true)
        end

        describe "expects to assign" do
          before { send_request }

          it { expect(assigns[:zipmoney_source]).to eq(zipmoney_source) }
        end

        describe "expects to receive" do
          it { expect(zipmoney_source).to receive(:transactions).and_return(transactions) }
          it { expect(transactions).to receive(:find_by).with(action: Spree::Zipmoney::CAPTURE_ACTION).and_return(transaction) }
          it { expect(transaction).to receive(:update!).with(success: true).and_return(true) }

          after { send_request }
        end
      end

      context "when charge_failed" do
        let(:transaction_id) { "12345" }
        let(:params) { { "Type" => "Notification", "Subject" => "charge_failed", "Message" => { "response" => { "txn_id" => transaction_id } }.to_json } }

        before do
          allow(zipmoney_source).to receive(:transactions).and_return(transactions)
          allow(transactions).to receive(:find_by).and_return(transaction)
          allow(transaction).to receive(:update!).and_return(true)
        end

        describe "expects to assign" do
          before { send_request }

          it { expect(assigns[:zipmoney_source]).to eq(zipmoney_source) }
        end

        describe "expects to receive" do
          it { expect(zipmoney_source).to receive(:transactions).and_return(transactions) }
          it { expect(transactions).to receive(:find_by).with(action: Spree::Zipmoney::CAPTURE_ACTION).and_return(transaction) }
          it { expect(transaction).to receive(:update!).with(success: false).and_return(true) }

          after { send_request }
        end
      end

      context "when capture_succeeded" do
        let(:transaction_id) { "12345" }
        let(:params) { { "Type" => "Notification", "Subject" => "capture_succeeded", "Message" => { "response" => { "txn_id" => transaction_id } }.to_json } }

        before do
          allow(zipmoney_source).to receive(:transactions).and_return(transactions)
          allow(transactions).to receive(:find_by).and_return(transaction)
          allow(transaction).to receive(:update!).and_return(true)
        end

        describe "expects to assign" do
          before { send_request }

          it { expect(assigns[:zipmoney_source]).to eq(zipmoney_source) }
        end

        describe "expects to receive" do
          it { expect(zipmoney_source).to receive(:transactions).and_return(transactions) }
          it { expect(transactions).to receive(:find_by).with(action: Spree::Zipmoney::CAPTURE_ACTION).and_return(transaction) }
          it { expect(transaction).to receive(:update!).with(success: true).and_return(true) }

          after { send_request }
        end
      end

      context "when capture_failed" do
        let(:transaction_id) { "12345" }
        let(:params) { { "Type" => "Notification", "Subject" => "capture_failed", "Message" => { "response" => { "txn_id" => transaction_id } }.to_json } }

        before do
          allow(zipmoney_source).to receive(:transactions).and_return(transactions)
          allow(transactions).to receive(:find_by).and_return(transaction)
          allow(transaction).to receive(:update!).and_return(true)
        end

        describe "expects to assign" do
          before { send_request }

          it { expect(assigns[:zipmoney_source]).to eq(zipmoney_source) }
        end

        describe "expects to receive" do
          it { expect(zipmoney_source).to receive(:transactions).and_return(transactions) }
          it { expect(transactions).to receive(:find_by).with(action: Spree::Zipmoney::CAPTURE_ACTION).and_return(transaction) }
          it { expect(transaction).to receive(:update!).with(success: false).and_return(true) }

          after { send_request }
        end
      end
    end
  end

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
