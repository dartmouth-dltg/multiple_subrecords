module MultiHelloWorldTwos

  def self.included(base)
    base.one_to_many :multi_hello_world_two

    base.def_nested_record(:the_property => :multi_hello_world_twos,
                           :contains_records_of_type => :multi_hello_world_two,
                           :corresponding_to_association  => :multi_hello_world_two,
                           :is_array => true)
  end

end
