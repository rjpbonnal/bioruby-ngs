class CreateGene < ActiveRecord::Migration

	def self.up
		create_table :genes do |t|
			t.string :gene_id
			t.string :library
		end
		
		add_index :genes, :gene_id
	end
	
	def	self.down
		drop_table :genes
	end

end