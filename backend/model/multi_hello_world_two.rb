class MultiHelloWorldTwo < Sequel::Model(:multi_hello_world_two)
  include ASModel
  
  corresponds_to JSONModel(:multi_hello_world_two)

  set_model_scope :global
  
end
