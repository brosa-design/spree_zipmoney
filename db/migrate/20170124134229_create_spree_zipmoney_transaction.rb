class CreateSpreeZipmoneyTransaction < SpreeExtension::Migration[4.2]
  def change
    create_table :spree_zipmoney_transactions do |t|
      t.references :source, index: true
      t.decimal :amount, scale: 2, precision: 8
      t.string :action
      t.string :authorization_code
      t.references :originator, polymorphic: true, index: { name: :index_spree_zipmoney_transactions_on_originator }
      t.boolean :success

      t.timestamps null: false
    end
  end
end
