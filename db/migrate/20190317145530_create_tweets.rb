class CreateTweets < ActiveRecord::Migration[5.2]
  def change
    create_table :tweets do |t|
      t.boolean :truncated
      t.integer :favorite_count
      t.integer :retweet_count
      t.text :text
      t.references :user

      t.timestamps
    end
  end
end
