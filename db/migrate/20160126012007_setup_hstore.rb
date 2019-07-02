class SetupHstore < ActiveRecord::Migration[5.2]
  def self.up
    enable_extension :hstore
  end

  def self.down
    disable_extension :hstore
  end
end
