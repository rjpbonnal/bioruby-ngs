#
#  enumerable.rb - Add Math functionalities to enumerable
#
# ToDo: refactor, it's not the right approach: used in Bio::Ngs::Cufflinks::Diff.process_de
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>,
#     Francesco Strozzi <francesco.strozzi@gmail.com>
# License:: The Ruby License
#
#

module Enumerable

  #  sum of an array of numbers
  def sum
    return self.inject(0){|acc,i|acc +i}
  end

  #  average of an array of numbers
  def average
    return self.sum/self.length.to_f
  end

  #  variance of an array of numbers
  def sample_variance
    avg=self.average
    sum=self.inject(0){|acc,i|acc +(i-avg)**2}
    return(1/self.length.to_f*sum)
  end

  #  standard deviation of an array of numbers
  def standard_deviation
    return Math.sqrt(self.sample_variance)
  end

end  #  module Enumerable