class CreateGoannotation < ActiveRecord::Migration
	
	def self.up
		create_table :go_annotations do |t|
			t.string :db
			t.string :entry_id
			t.string :symbol
			t.string :qualifier
			t.string :go_id
			t.string :db_ref
			t.string :evidence
			t.string :additional_identifier
			t.string :aspect
			t.string :name
			t.string :synonym
			t.string :molecule_type
			t.string :taxon_id
			t.string :date
			t.string :assigned_by
		end
		
		add_index :go_annotations, :entry_id
	end
	
	def	self.down
		drop_table :go_annotations
	end

end