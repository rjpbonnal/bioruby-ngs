class CreateGo < ActiveRecord::Migration
	
	def self.up
		create_table :go do |t|
			t.string :go_id
			t.string :name
			t.string :namespace
			t.string :is_a
		end
		
		add_index :go, :go_id
	end
	
	def	self.down
		drop_table :go
	end

end