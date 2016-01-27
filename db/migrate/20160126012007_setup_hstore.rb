class SetupHstore < ActiveRecord::Migration
  def self.up
    enable_extension :hstore
  end

  def self.down
    disable_extension :hstore
  end
end
