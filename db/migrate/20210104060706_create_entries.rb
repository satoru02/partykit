class CreateEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :entries do |t|
      t.boolean :activated

      t.timestamps
    end
  end
end
