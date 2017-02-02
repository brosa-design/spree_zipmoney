require 'spec_helper'

describe Spree::Zipmoney, type: :model do
  # Associations
  it { is_expected.to have_many(:transactions).class_name('Spree::ZipmoneyTransaction').dependent(:destroy) }
  it { is_expected.to have_one(:payment).class_name('Spree::Payment') }
  it { is_expected.to belong_to(:payment_method).class_name('Spree::PaymentMethod') }
  it { is_expected.to belong_to(:user) }

  # Constants
  it { expect(Spree::Zipmoney::ALLOCATION_ACTION).to eq('allocation') }
  it { expect(Spree::Zipmoney::AUTHORIZE_ACTION).to eq('authorize') }
  it { expect(Spree::Zipmoney::CAPTURE_ACTION).to eq('capture') }
  it { expect(Spree::Zipmoney::VOID_ACTION).to eq('void') }

  # Validations
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:payment_method) }
  it { is_expected.to validate_numericality_of(:amount_allocated).is_greater_than(0).allow_nil }

    def checkout(amount, options = {})
      zipmoney_service = Spree::ZipmoneyService.new(self, options)
      if zipmoney_service.checkout
        transactions.build(
          action: ALLOCATION_ACTION,
          amount: amount,
          originator: options[:action_originator],
          success: true
        )
        self.amount_allocated = amount
        save!
      end
    end

  describe "checkout" do
    let(:zipmoney) { create(:zipmoney) }
    let(:zipmoney_service) { double(Spree::ZipmoneyService) }
    let(:checkout_amount) { 13.0 }

    def zipmoney_checkout
      zipmoney.checkout(checkout_amount)
    end

    before do
      allow(Spree::ZipmoneyService).to receive(:new).and_return(zipmoney_service)
    end

    context "when checked out from zipmoney" do
      before do
        allow(zipmoney_service).to receive(:checkout).and_return(true)
      end

      it "expects to return true" do
        expect(zipmoney_checkout).to be_truthy
      end

      it "expects amount_allocated to equal checkout_amount" do
        zipmoney_checkout
        expect(zipmoney.amount_allocated).to eq(checkout_amount)
      end

      it "expects to create a allocation transaction for the given amount" do
        zipmoney_checkout
        expect(zipmoney.transactions.where(action: Spree::Zipmoney::ALLOCATION_ACTION, amount: checkout_amount).exists?).to be_truthy
      end
    end

    context "when not checked out from zipmoney" do
      before do
        allow(zipmoney_service).to receive(:checkout).and_return(false)
      end

      it "expects to return false" do
        expect(zipmoney_checkout).to be_falsey
      end

      it "expects amount_allocated to not equal checkout_amount" do
        zipmoney_checkout
        expect(zipmoney.amount_allocated).to_not eq(checkout_amount)
      end

      it "expects not to create a allocation transaction for the given amount" do
        zipmoney_checkout
        expect(zipmoney.transactions.where(action: Spree::Zipmoney::ALLOCATION_ACTION, amount: checkout_amount).exists?).to be_falsey
      end
    end
  end

  describe "authorize" do
    let(:zipmoney) { create(:zipmoney) }

    def zipmoney_authorize
      zipmoney.authorize(authorized_amount)
    end

    context "when already authorized" do
      let(:auth_code) { "1234567890" }
      let(:authorized_amount) { 13.0 }

      before do
        zipmoney.transactions.create!(action: Spree::Zipmoney::AUTHORIZE_ACTION, amount: authorized_amount, authorization_code: auth_code, success: true)
      end

      it "expects to return true" do
        expect(zipmoney.authorize(authorized_amount, action_authorization_code: auth_code)).to be_truthy
      end

      it "expects not to re-authorize given amount" do
        expect {
          zipmoney.authorize(authorized_amount, action_authorization_code: auth_code)
        }.to_not change { zipmoney.transactions.count }
      end
    end

    context "when not authorized previously" do
      context "when amount allocated" do
        let(:authorized_amount)  { 13.0 }

        before do
          zipmoney.transactions.create!(action: Spree::Zipmoney::ALLOCATION_ACTION, amount: authorized_amount, success: true)
        end

        it "expects not to return true" do
          expect(zipmoney_authorize).to be_truthy
        end

        it "expects to create an authorize transaction for the given amount" do
          zipmoney_authorize
          expect(zipmoney.transactions.where(action: Spree::Zipmoney::AUTHORIZE_ACTION, amount: authorized_amount).exists?).to be_truthy
        end
      end

      context "when amount not allocated" do
        let(:authorized_amount)  { 13.0 }

        it "expects not to return false" do
          expect(zipmoney_authorize).to be_falsey
        end

        it "expects to add error to zipmoney" do
          zipmoney_authorize
          expect(zipmoney.errors[:base]).to include(Spree.t(:no_amount_allocation, scope: [:zipmoney_payment_method]))
        end

        it "expects not to create an authorize transaction for the given amount" do
          zipmoney_authorize
          expect(zipmoney.transactions.where(action: Spree::Zipmoney::AUTHORIZE_ACTION, amount: authorized_amount).exists?).to be_falsey
        end
      end
    end
  end

  describe "capture" do
    let(:zipmoney_transaction) { create(:zipmoney_transaction) }
    let(:zipmoney) { zipmoney_transaction.source }
    let(:auth_code) { zipmoney_transaction.authorization_code }
    let(:zipmoney_service) { double(Spree::ZipmoneyService) }
    let(:capture_amount) { 13.0 }

    before do
      allow(Spree::ZipmoneyService).to receive(:new).and_return(zipmoney_service)
      allow(zipmoney_service).to receive(:capture).and_return(true)
    end

    def zipmoney_capture
      zipmoney.capture(capture_amount, auth_code)
    end

    context "when not already authorized" do
      it "expects to return false" do
        expect(zipmoney_capture).to be_falsey
      end

      it "expects not to create capture transaction" do
        expect {
          zipmoney_capture
        }.to_not change { zipmoney.transactions.where(action: Spree::Zipmoney::CAPTURE_ACTION).count }
      end
    end

    context "when authorized" do
      before do
        zipmoney.transactions.create!(action: Spree::Zipmoney::AUTHORIZE_ACTION, authorization_code: auth_code, amount: capture_amount, success: true)
      end

      context "when captured from zipmoney" do
        before do
          allow(zipmoney_service).to receive(:capture).and_return(true)
        end

        it "expects to return true" do
          expect(zipmoney_capture).to be_truthy
        end

        it "expects to create a capture transaction for the given amount" do
          zipmoney_capture
          expect(zipmoney.transactions.where(action: Spree::Zipmoney::CAPTURE_ACTION, amount: capture_amount).exists?).to be_truthy
        end
      end

      context "when not captured from zipmoney" do
        before do
          allow(zipmoney_service).to receive(:capture).and_return(false)
        end

        it "expects to return false" do
          expect(zipmoney_capture).to be_falsey
        end

        it "expects to add error to zipmoney" do
          zipmoney_capture
          expect(zipmoney.errors[:base]).to include(Spree.t(:unable_to_capture, scope: [:zipmoney_payment_method], auth_code: auth_code))
        end

        it "expects not to create a capture transaction for the given amount" do
          zipmoney_capture
          expect(zipmoney.transactions.where(action: Spree::Zipmoney::CAPTURE_ACTION, amount: capture_amount).exists?).to be_falsey
        end
      end
    end
  end

  describe "void" do
    let(:zipmoney) { create(:zipmoney) }
    let(:auth_code) { "123456789" }
    let(:zipmoney_service) { double(Spree::ZipmoneyService) }
    let(:void_amount) { 13.0 }

    before do
      allow(Spree::ZipmoneyService).to receive(:new).and_return(zipmoney_service)
      allow(zipmoney_service).to receive(:cancel).and_return(true)
    end

    def zipmoney_void
      zipmoney.void(auth_code)
    end

    context "when not already authorized" do
      it "expects to return false" do
        expect(zipmoney_void).to be_falsey
      end

      it "expects to add error to zipmoney" do
        zipmoney_void
        expect(zipmoney.errors[:base]).to include(Spree.t(:unable_to_void, scope: [:zipmoney_payment_method], auth_code: auth_code))
      end

      it "expects not to create void transaction" do
        expect {
          zipmoney_void
        }.to_not change { zipmoney.transactions.where(action: Spree::Zipmoney::VOID_ACTION).count }
      end
    end

    context "when authorized" do
      before do
        zipmoney.transactions.create!(action: Spree::Zipmoney::AUTHORIZE_ACTION, authorization_code: auth_code, amount: void_amount, success: true)
      end

      context "when cancelled from zipmoney" do
        before do
          allow(zipmoney_service).to receive(:cancel).and_return(true)
        end

        it "expects to return true" do
          expect(zipmoney_void).to be_truthy
        end

        it "expects to create a void transaction for the given amount" do
          zipmoney_void
          expect(zipmoney.transactions.where(action: Spree::Zipmoney::VOID_ACTION, amount: void_amount).exists?).to be_truthy
        end
      end

      context "when not cancelled from zipmoney" do
        before do
          allow(zipmoney_service).to receive(:cancel).and_return(false)
        end

        it "expects to return false" do
          expect(zipmoney_void).to be_falsey
        end

        it "expects to add error to zipmoney" do
          zipmoney_void
          expect(zipmoney.errors[:base]).to include(Spree.t(:unable_to_void, scope: [:zipmoney_payment_method], auth_code: auth_code))
        end

        it "expects not to create a void transaction for the given amount" do
          zipmoney_void
          expect(zipmoney.transactions.where(action: Spree::Zipmoney::VOID_ACTION, amount: void_amount).exists?).to be_falsey
        end
      end
    end
  end
end
