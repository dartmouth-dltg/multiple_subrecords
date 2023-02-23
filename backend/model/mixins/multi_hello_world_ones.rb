module MultiHelloWorldOnes

  def self.included(base)
    base.one_to_many :multi_hello_world_one

    base.def_nested_record(:the_property => :multi_hello_world_ones,
                           :contains_records_of_type => :multi_hello_world_one,
                           :corresponding_to_association  => :multi_hello_one,
                           :is_array => true)
  end

end
