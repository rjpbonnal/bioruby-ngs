class CreateBlastout < ActiveRecord::Migration

 def self.up
	create_table :blast_outputs do |t|
		t.string :query_id
		t.string :target_id
		t.string :target_description
		t.float :evalue, :precision => :double
		t.float	:identity
		t.float :positive
	end
	
	add_index :blast_outputs, :query_id
	
 end

 def self.down
	drop_table :blast_outputs
 end


end