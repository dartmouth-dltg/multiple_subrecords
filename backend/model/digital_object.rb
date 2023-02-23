require_relative 'mixins/multi_hellow_world_one.rb'
require_relative 'mixins/multi_hellow_world_two.rb'

class DigitalObject
  include MultiHellowWorldOne
  include MultiHellowWorldTwo
end