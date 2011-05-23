class Go < ActiveRecord::Base
  set_table_name "go"
  has_many :genes, :through => :gene_gos
  has_many :gene_gos
  
end

class Gene < ActiveRecord::Base
  has_many :go, :through => :gene_gos
  has_many :gene_gos
end

class GeneGo < ActiveRecord::Base
  belongs_to :gene
  belongs_to :go
end