class MultiHelloWorldOne < Sequel::Model(:multi_hello_world_one)
  include ASModel
  
  corresponds_to JSONModel(:multi_hello_world_one)

  set_model_scope :global
  
end
