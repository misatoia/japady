class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :area_of_residence
      t.string :purpose
      t.boolean :member
      t.boolean :manager
      t.boolean :admin
      t.datetime :authorized_at
      t.references :authorized_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
