
class GoAnnotation < ActiveRecord::Base
  belongs_to :blast_output
  has_one :go, :foreign_key => "go_id", :primary_key => "go_id"
end

class BlastOutput < ActiveRecord::Base
  has_many :go_annotations, :foreign_key => "entry_id", :primary_key => "target_id"
end