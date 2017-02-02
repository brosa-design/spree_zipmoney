require 'spec_helper'

describe Spree::PaymentMethod, type: :model do
  describe ".zipmoney" do
    context "when payment method of type zipmoney" do
      let!(:payment_method) { create(:zipmoney_payment_method) }

      it "expects to be included in zipmoney payment methods" do
        expect(Spree::PaymentMethod.zipmoney).to include(payment_method)
      end
    end

    context "when payment method not of type zipmoney" do
      let!(:payment_method) { create(:credit_card_payment_method) }

      it "expects not to be included in zipmoney payment methods" do
        expect(Spree::PaymentMethod.zipmoney).to_not include(payment_method)
      end
    end
  end
end
