
#use CSV to iterate over all the genes expressed during the differential expression.

module Bio
  module Ngs          
    module Cufflinks
      class Diff
        module Utils
          
          def self.included(base)
            base.extend(ClassMethods)
          end            
          
          module ClassMethods
            require 'csv'            
            # Create an iterator using the specified type_name file.
            # in case of Cufflinks type_file_name can be gene,isoform, cds, tss_group
            def add_iterator_for( type_file_name, opts={})
              plural_name = type_file_name = type_file_name.to_s
              if %w(genes isoforms cds tss_groups).include?(type_file_name)
                type_file_name=type_file_name[0..-2] if type_file_name!="cds"
                self.class.send  :define_method, "foreach_#{type_file_name}_tracked" do |path = '.', &block|
                  file_name = File.join(path,"#{plural_name}.fpkm_tracking")
                  CSV.foreach(file_name, headers: true, converters: :numeric, col_sep:"\t") do |data|
                    block.call(data)
                  end #cvs_foreach
                end #define_method
             else
                raise "#{type_file_name} is not a valid base name for cuffdiff's output, must be plural and in this set: genes, cds, isoforms, tss_groups"
             end #if
            end #iterator
          end #ClassMethod
        end #Utils
      end #Diff
    end #Cufflinks
  end #Ngs
end #Bio