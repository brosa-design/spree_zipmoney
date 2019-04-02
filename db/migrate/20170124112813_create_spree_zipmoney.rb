class CreateSpreeZipmoney < SpreeExtension::Migration[4.2]
  def change
    create_table :spree_zipmoneys do |t|
      t.references :payment_method, index: true
      t.references :user, index: true
      t.string :email
      t.string :transaction_id
      t.string :redirect_url
      t.decimal :amount_allocated, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
