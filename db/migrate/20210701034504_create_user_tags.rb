class CreateUserTags < ActiveRecord::Migration[6.1]
  def change
    create_table :user_tags do |t|
      t.bigint :user_id, index: true
      t.string :name, index: true

      t.timestamps
    end
  end
end