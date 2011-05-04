class Go < ActiveRecord::Base
  set_table_name "go"
  belongs_to :go_annotation
end

class GoCount < ActiveRecord::Base

end