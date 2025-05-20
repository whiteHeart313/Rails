class CreateEmails < ActiveRecord::Migration[8.0]
  def change
    create_table :emails do |t|
      t.string :password_digest
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
