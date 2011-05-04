class CreateGoCount < ActiveRecord::Migration

	def self.up
		create_table :go_counts do |t|
			t.string :go_id
			t.string :count
		end
		
		add_index :go_counts, :go_id
	end
	
	def	self.down
		drop_table :go_counts
	end

end