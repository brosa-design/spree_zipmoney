Spree::Payment.class_eval do
  scope :zipmoney, -> { joins(:payment_method).where(spree_payment_methods: { type: Spree::PaymentMethod::Zipmoney.to_s }) }
  scope :non_zipmoney, -> { joins(:payment_method).where.not(spree_payment_methods: { type: Spree::PaymentMethod::Zipmoney.to_s }) }

  delegate :zipmoney?, to: :payment_method, prefix: true, allow_nil: true

  state_machine.after_transition to: :invalid, do: :cancel_zipmoney_payment, if: :payment_method_zipmoney?

  def cancel_zipmoney_payment
    if source.transaction_id && source.cancelable?
      zipmoney_service = Spree::ZipmoneyService.new(source, {})
      if zipmoney_service.cancel
        source.transactions.create!(action: Spree::Zipmoney::VOID_ACTION, amount: source.amount_allocated)
      else
        errors.add(:base, Spree.t(:unable_to_invalidate, scope: [:zipmoney_payment_method]))
        raise ActiveRecord::RecordInvalid.new(self)
      end
    end
  end
end
