require 'spec_helper'

describe Spree::PaymentMethod::Zipmoney do
  let(:order) { create(:order) }
  let(:payment) { create(:payment, order: order) }
  let(:gateway_options) { payment.gateway_options }

  context '#authorize' do
    subject do
      Spree::PaymentMethod::Zipmoney.new.authorize(auth_amount, zipmoney, gateway_options)
    end

    let(:auth_amount) { zipmoney.amount_allocated * 100 }
    let(:zipmoney) { create(:zipmoney) }

    context 'with invalid zipmoney' do
      let(:zipmoney) { nil }
      let(:auth_amount) { 10 }

      it 'declines an unknown zipmoney' do
        is_expected.to_not be_success
      end

      it 'adds unable_to_find message' do
        expect(subject.message).to include Spree.t(:unable_to_find, scope: [:zipmoney_payment_method])
      end
    end

    context 'with more than allocated_amount' do
      let(:auth_amount) { (zipmoney.amount_allocated * 100) + 1 }

      it 'declines a gift card' do
        is_expected.to_not be_success
      end

      it 'adds no_amount_allocation message' do
        expect(subject.message).to include Spree.t(:no_amount_allocation, scope: [:zipmoney_payment_method])
      end
    end

    context 'with amount allocated' do
      before do
        zipmoney.transactions.create!(action: Spree::Zipmoney::ALLOCATION_ACTION, amount: auth_amount/100.to_d, success: true)
      end

      it 'authorizes a valid gift card' do
        is_expected.to be_success
      end

      it 'adds a authorization code' do
        expect(subject.authorization).to_not be_nil
      end
    end
  end

  context '#capture' do
    subject do
      Spree::PaymentMethod::Zipmoney.new.capture(capture_amount, auth_code, gateway_options)
    end

    let(:capture_amount) { 10_00 }
    let(:auth_code) { zipmoney_transaction.authorization_code }

    let(:authorized_amount) { capture_amount / 100.0 }
    let(:zipmoney_transaction) { create(:zipmoney_transaction, source: zipmoney, amount: authorized_amount, action: Spree::Zipmoney::AUTHORIZE_ACTION) }
    let(:zipmoney) { create(:zipmoney, amount_allocated: authorized_amount) }
    let(:zipmoney_service) { double(Spree::Zipmoney) }

    before do
      allow(Spree::ZipmoneyService).to receive(:new).and_return(zipmoney_service)
      allow(zipmoney_service).to receive(:capture).and_return(true)
    end

    context 'with an invalid auth code' do
      let(:auth_code) { -1 }

      it 'declines an unknown zipmoney' do
        is_expected.to_not be_success
      end

      it 'adds unable_to_find message' do
        expect(subject.message).to include Spree.t(:unable_to_find, scope: [:zipmoney_payment_method])
      end
    end

    context 'when unable to authorize the amount' do
      let(:authorized_amount) { (capture_amount - 1) / 100.to_d }

      it 'declines payment' do
        is_expected.to_not be_success
      end

      it 'adds no_amount_allocation message' do
        expect(subject.message).to include Spree.t(:no_amount_allocation, scope: [:zipmoney_payment_method])
      end
    end

    context 'with a valid request' do
      before do
        allow_any_instance_of(Spree::Zipmoney).to receive(:authorize).and_return(true)
      end

      it 'captures the payment' do
        is_expected.to be_success
      end

      it 'adds successful_action capture message' do
        expect(subject.message).to include Spree.t(:successful_action, scope: [:zipmoney_payment_method],
                                                   action: Spree::Zipmoney::CAPTURE_ACTION)
      end
    end
  end

  context '#void' do
    subject do
      Spree::PaymentMethod::Zipmoney.new.void(auth_code, gateway_options)
    end

    let(:auth_code) { zipmoney_transaction.authorization_code }
    let(:zipmoney_transaction) { create(:zipmoney_transaction, action: Spree::Zipmoney::AUTHORIZE_ACTION) }
    let(:zipmoney_service) { double(Spree::Zipmoney) }

    before do
      allow(Spree::ZipmoneyService).to receive(:new).and_return(zipmoney_service)
      allow(zipmoney_service).to receive(:cancel).and_return(true)
    end

    context 'with an invalid auth code' do
      let(:auth_code) { 1 }

      it 'declines an unknown payment' do
        is_expected.to_not be_success
      end

      it 'adds unable_to_find message' do
        expect(subject.message).to include Spree.t(:unable_to_find, scope: [:zipmoney_payment_method])
      end
    end

    context 'when the payment is not voided successfully' do
      before { allow(zipmoney_service).to receive(:cancel).and_return(false) }

      it 'returns an error response' do
        is_expected.to_not be_success
      end

      it 'adds unable_to_void message' do
        expect(subject.message).to include Spree.t(:unable_to_void, scope: [:zipmoney_payment_method], auth_code: auth_code)
      end
    end

    it 'voids the payment' do
      is_expected.to be_success
    end

    it 'adds successful_action void message' do
      expect(subject.message).to include Spree.t(:successful_action, scope: [:zipmoney_payment_method],
                                                 action: Spree::Zipmoney::VOID_ACTION)
    end
  end

  context '#purchase' do
    subject do
      Spree::PaymentMethod::Zipmoney.new.purchase(purchase_amount, zipmoney, gateway_options)
    end

    let(:purchase_amount) { 10_00 }
    let(:authorized_amount) { purchase_amount / 100.0 }
    let(:allocated_amount) { purchase_amount / 100.0 }
    let(:zipmoney_transaction) { create(:zipmoney_transaction, source: zipmoney, amount: authorized_amount, action: Spree::Zipmoney::AUTHORIZE_ACTION) }
    let(:allocation_transaction) { create(:zipmoney_transaction, source: zipmoney, amount: allocated_amount, action: Spree::Zipmoney::ALLOCATION_ACTION) }
    let(:zipmoney) { create(:zipmoney, amount_allocated: authorized_amount) }
    let(:zipmoney_service) { double(Spree::Zipmoney) }

    before do
      allow(Spree::ZipmoneyService).to receive(:new).and_return(zipmoney_service)
      allow(zipmoney_service).to receive(:capture).and_return(true)
      allocation_transaction
    end

    context 'when unable to authorize the amount' do
      let(:authorized_amount) { (purchase_amount - 1) / 100.to_d }

      it 'declines payment' do
        is_expected.to_not be_success
      end

      it 'adds no_amount_allocation message' do
        expect(subject.message).to include Spree.t(:no_amount_allocation, scope: [:zipmoney_payment_method])
      end
    end

    context 'with a valid request' do
      before do
        allow_any_instance_of(Spree::Zipmoney).to receive(:authorize).and_return(true)
      end

      it 'purchases the payment' do
        is_expected.to be_success
      end

      it 'adds successful_action capture message' do
        expect(subject.message).to include Spree.t(:successful_action, scope: [:zipmoney_payment_method],
                                                   action: Spree::Zipmoney::CAPTURE_ACTION)
      end
    end
  end
end
