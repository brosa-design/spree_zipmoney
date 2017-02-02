require 'spec_helper'

describe Spree::Payment, type: :model do
  let(:zipmoney_payment_method) { create(:zipmoney_payment_method) }

  describe ".zipmoney" do
    context "when payment using zipmoney" do
      let!(:payment) { create(:zipmoney_payment, payment_method: zipmoney_payment_method) }

      it "expects to be included in zipmoney payments" do
        expect(Spree::Payment.zipmoney).to include(payment)
      end
    end

    context "when payment not using zipmoney" do
      let!(:payment) { create(:payment) }

      it "expects not to be included in zipmoney payments" do
        expect(Spree::Payment.zipmoney).not_to include(payment)
      end
    end
  end

  describe ".non_zipmoney" do
    context "when payment using zipmoney" do
      let!(:payment) { create(:zipmoney_payment, payment_method: zipmoney_payment_method) }

      it "expects not to be included in non_zipmoney payments" do
        expect(Spree::Payment.non_zipmoney).to_not include(payment)
      end
    end

    context "when payment not using zipmoney" do
      let!(:payment) { create(:payment) }

      it "expects to be included in non_zipmoney payments" do
        expect(Spree::Payment.non_zipmoney).to include(payment)
      end
    end
  end
end
