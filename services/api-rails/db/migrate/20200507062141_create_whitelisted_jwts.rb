class CreateWhitelistedJwts < ActiveRecord::Migration[6.0]
  def change
    create_table :whitelisted_jwts do |t|
      t.references :user, foreign_key: { on_delete: :cascade }, null: false
      t.string :jti, null: false
      t.string :aud
      # t.string :aud, null: false # null: false not working in tests...
      t.datetime :exp, null: false
    end

    add_index :whitelisted_jwts, :jti, unique: true
  end
end
