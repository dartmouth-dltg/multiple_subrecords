require_relative 'mixins/multi_hello_world_ones.rb'
require_relative 'mixins/multi_hello_world_twos.rb'

class DigitalObject
  include MultiHelloWorldOnes
  include MultiHelloWorldTwos
end