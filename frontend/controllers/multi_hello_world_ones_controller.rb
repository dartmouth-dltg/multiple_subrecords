class MultiHelloWorldOnesController < ApplicationController

  set_access_control "view_repository" => [:index]

  def index
    @multi_hello_world_one = "Hello from multi one"
  end
end