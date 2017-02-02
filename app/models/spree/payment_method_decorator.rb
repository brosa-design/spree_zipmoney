Spree::PaymentMethod.class_eval do
  scope :zipmoney, -> { where(type: "Spree::PaymentMethod::Zipmoney") }
end