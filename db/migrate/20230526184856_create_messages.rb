class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.string :content
      t.string :role
      t.integer :word_id
      t.integer :user_id

      t.timestamps
    end
  end
end
