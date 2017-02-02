require 'spec_helper'

describe Spree::ZipmoneyTransaction, type: :model do
  # Associations
  it { is_expected.to belong_to(:source).class_name('Spree::Zipmoney') }
  it { is_expected.to belong_to(:originator) }

  # Validations
  it { is_expected.to validate_presence_of(:source) }
  it { is_expected.to validate_presence_of(:action) }
  it { is_expected.to validate_presence_of(:amount) }
  it { is_expected.to validate_numericality_of(:amount).is_greater_than(0).allow_nil }
end
