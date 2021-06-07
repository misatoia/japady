class CreateLessons < ActiveRecord::Migration[5.2]
  def change
    create_table :lessons do |t|
      t.string :name
      t.references :user, foreign_key: true
      t.datetime :started_at
      t.datetime :ended_at
      t.string :remarks

      t.timestamps
    end
  end
end
