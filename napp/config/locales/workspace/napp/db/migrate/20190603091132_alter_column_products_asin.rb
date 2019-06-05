class AlterColumnProductsAsin < ActiveRecord::Migration[5.2]
  def change
            add_index :products, :asin, unique: true
  end
end
