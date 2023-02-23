class MultiHelloWorldTwosController < ApplicationController

  set_access_control "view_repository" => [:index]

  def index
    @multi_hello_world_two = "Hello from multi two"
  end
end