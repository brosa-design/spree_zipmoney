Spree::Payment.class_eval do
  scope :zipmoney, -> { joins(:payment_method).where(spree_payment_methods: { type: Spree::PaymentMethod::Zipmoney.to_s }) }
  scope :non_zipmoney, -> { joins(:payment_method).where.not(spree_payment_methods: { type: Spree::PaymentMethod::Zipmoney.to_s }) }
end
