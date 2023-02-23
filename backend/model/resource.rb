require_relative 'mixins/multi_hello_world_ones.rb'
require_relative 'mixins/multi_hello_world_twos.rb'

class Resource
  include MultiHelloWorldOnes
  include MultiHelloWorldTwos
end