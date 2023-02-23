require_relative 'mixins/multi_hello_world_ones.rb'
require_relative 'mixins/multi_hello_world_twos.rb'

class Accession
  include MultiHelloWorldOnes
  include MultiHelloWorldTwos
end