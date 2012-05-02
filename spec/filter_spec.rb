require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'thor/base'

describe Filter do 
  describe "#by_list" do
  	it 'finds rows with first column equal to TCONS_00000005 or TCONS_00000010' do
      table = File.expand_path(File.dirname(__FILE__) + '/fixture/table_filter_source.tsv')
      list = File.expand_path(File.dirname(__FILE__) + '/fixture/table_filter_list_first_column.txt')
      filter = Filter.new

      data = capture(:stdout){filter.invoke(:by_list, [table, list], :skip_table_header => true, :skip_list_header => false, :zero_index_system=>true)}
      data.should == "TCONS_00000005  =       uc001aaq.1      XLOC_000003     QUERTY,JIM       -       chr1:321083-321114      31      -       0       0       0       OK      0       0       0       OK      0       0       0       OK\nTCONS_00000010  =       uc010nxu.1      XLOC_000006     OR4F16  -       chr1:367658-368595      937     -       0       0       0       OK      0       0       0       OK      9.00455 0       27.0137 OK\n"
  	end

  	it 'finds rows with 5th column equal to JIM or WATSON or SAMD11' do
      table = File.expand_path(File.dirname(__FILE__) + '/fixture/table_filter_source.tsv')
      list = File.expand_path(File.dirname(__FILE__) + '/fixture/table_filter_list.txt')
      filter = Filter.new

      data = capture(:stdout){filter.invoke(:by_list, [table, list], :skip_table_header => true, :skip_list_header => false, :zero_index_system=>true, :tablekey=>4, :in_column_delimiter=>',')}
      data.should == "TCONS_00000005  =       uc001aaq.1      XLOC_000003     QUERTY,JIM       -       chr1:321083-321114      31      -       0       0       0       OK      0       0       0       OK      0       0       0       OK\nTCONS_00000014  =       uc001abb.2      XLOC_000010     CRICK,WATSON       -       chr1:568843-568912      69      -       0       0       0       OK      0       0       0       OK      0       0       0       OK\nTCONS_00000023  =       uc001abv.1      XLOC_000015     SAMD11  TSS7    chr1:860529-894679      490     -       1.40488 0       10.5489 OK      3.5127  0       12.9469 OK      372.514 0       4986.76 OK\nTCONS_00000024  =       uc001abw.1      XLOC_000015     SAMD11  TSS8    chr1:860529-894679      2554    -       2.92757 0.0526766       5.80247 OK      2.54641 0       5.1809  OK      64.8329 0       645.748 OK\nTCONS_00000025  =       uc001abx.1      XLOC_000015     SAMD11  TSS9    chr1:860529-894679      2121    -       7.77732 2.80074 12.7539 OK      45.2404 11.7902 78.6907 OK      176.15  0       750.086 OK\n"
  	end

  end
end