FactoryGirl.define do
  factory :zipmoney, class: Spree::Zipmoney do
    amount_allocated { 100.00 }
    email 'spree@example.com'
    transaction_id { "123456789" }
    payment_method { create(:zipmoney_payment_method) }
  end

  factory :zipmoney_payment_method, class: Spree::PaymentMethod::Zipmoney do
    type "Spree::PaymentMethod::Zipmoney"
    name "Zipmoney"
    description "Zipmoney"
    active true
    auto_capture false
  end

  factory :zipmoney_payment, class: Spree::Payment, parent: :payment do
    association(:source, factory: :zipmoney)
  end

  factory :zipmoney_transaction, class: Spree::ZipmoneyTransaction do
    association(:source, factory: :zipmoney)
    action { Spree::Zipmoney::AUTHORIZE_ACTION }
    amount { 100.00 }
    authorization_code { "123456789" }
  end
end
