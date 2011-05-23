
class GoAnnotation < ActiveRecord::Base
  belongs_to :blast_output
end

class BlastOutput < ActiveRecord::Base
  has_many :go_annotations, :foreign_key => "entry_id", :primary_key => "target_id"
end