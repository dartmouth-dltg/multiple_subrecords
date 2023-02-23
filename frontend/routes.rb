ArchivesSpace::Application.routes.draw do
    [AppConfig[:frontend_proxy_prefix], AppConfig[:frontend_prefix]].uniq.each do |prefix|
      scope prefix do
        match('plugins/multi_hello_world_ones' => 'multi_hello_world_ones#index', :via => [:get])        
        match('plugins/multi_hello_world_twos' => 'multi_hello_world_twos#index', :via => [:get])
      end
    end
  end
  