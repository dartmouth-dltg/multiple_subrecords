ArchivesSpace::Application.extend_aspace_routes(File.join(File.dirname(__FILE__), "routes.rb"))

ArchivesSpace::Application.config.after_initialize do

  Plugins.module_eval do

    def self.init
      @config = {:system_menu_items => [], :repository_menu_items => [], :plugin => {}, :parents => {}}
      Array(AppConfig[:plugins]).each do |plugin|
        # config.yml is optional, so defaults go here
        @config[:plugin][plugin] = {'parents' => []}
        plugin_dir = ASUtils.find_local_directories(nil, plugin).shift

        config_path = File.join(plugin_dir, 'config.yml')
        if File.exist?(config_path)
          @config[:plugin][plugin] = cfg = YAML.load_file config_path
          @config[:system_menu_items].concat(cfg['system_menu_controller'].split(',')) if cfg['system_menu_controller']
          @config[:repository_menu_items].concat(cfg['repository_menu_controller'].split(',')) if cfg['repository_menu_controller']
          (cfg['parents'] || {}).keys.each do |parent|
            @config[:parents][parent] ||= []
            @config[:parents][parent] << plugin
          end
        end
      end

      if @config[:system_menu_items].length > 0
        puts "Found system menu items for plug-ins: #{system_menu_items.inspect}"
      end

      if @config[:repository_menu_items].length > 0
        puts "Found repository menu items for plug-ins: #{repository_menu_items.inspect}"
      end

      @sections = []
      @fields_to_resolve = []
      @edit_roles = []

      @base_facets = []
      @facets_for_type = {}

      @facet_group_i18n_handlers = {}

      @note_types_handlers = []
    end
  end

end
  
Rails.application.config.after_initialize do
  PluginHelper.module_eval do

    def sidebar_plugins_for(record)
      result = ''
      jsonmodel_type = record['jsonmodel_type']
      Plugins.plugins_for(jsonmodel_type).each do |plugin|
        # addition
        # split on commas and check each name entry
        names = Plugins.parent_for(plugin, jsonmodel_type)['name']
        names.split(',').each do |name|
          if not controller.action_name === "show" or Array(record.send(name)).length > 0
            result << '<li>'
            result << "<a href='##{jsonmodel_type}_#{name}_'>"
            result << I18n.t("plugins.#{plugin}._plural")
            result << '<span class="glyphicon glyphicon-chevron-right"></span></a></li>'
          end
        end
      end

      mode = controller.action_name === 'show' ? :readonly : :edit
      Plugins.sections_for(record, mode).each do |plugin_section|
        result << plugin_section.render_sidebar(self, record, mode)
      end

      result.html_safe
    end


    def show_plugins_for(record, context)
      result = ''
      jsonmodel_type = record['jsonmodel_type']
      Plugins.plugins_for(jsonmodel_type).each do |plugin|
        # addition
        # split on commas and check each name entry
        names = Plugins.parent_for(plugin, jsonmodel_type)['name']
        names.split(',').each do |name|
          if Array(record.send(name)).length > 0
            result << render_aspace_partial(:partial => "#{name}/show",
                              :locals => { name.intern => record.send(name),
                              :context => context, :section_id => "#{jsonmodel_type}_#{name}_" })
          end
        end
      end

      Plugins.sections_for(record, :readonly).each do |sub_record|
        result << sub_record.render_readonly(self, record, context)
      end

      result.html_safe
    end
  end
  module PluginHelper

    def sidebar_plugins_for(record)
      result = ''
      jsonmodel_type = record['jsonmodel_type']
      Plugins.plugins_for(jsonmodel_type).each do |plugin|
        # addition
        # split on commas and check each name entry
        names = Plugins.parent_for(plugin, jsonmodel_type)['name']
        names.split(',').each do |name|      
          if not controller.action_name === "show" or Array(record.send(name)).length > 0
            result << '<li>'
            result << "<a href='##{jsonmodel_type}_#{name}_'>"
            result << I18n.t("plugins.#{plugin}._plural")
            result << '<span class="glyphicon glyphicon-chevron-right"></span></a></li>'
          end
        end
      end

      mode = controller.action_name === 'show' ? :readonly : :edit
      Plugins.sections_for(record, mode).each do |plugin_section|
        result << plugin_section.render_sidebar(self, record, mode)
      end

      result.html_safe
    end


    def show_plugins_for(record, context)
      result = ''
      jsonmodel_type = record['jsonmodel_type']
      Plugins.plugins_for(jsonmodel_type).each do |plugin|
        # addition
        # split on commas and check each name entry
        names = Plugins.parent_for(plugin, jsonmodel_type)['name']
        names.split(',').each do |name|
          if Array(record.send(name)).length > 0
            result << render_aspace_partial(:partial => "#{name}/show",
                              :locals => { name.intern => record.send(name),
                              :context => context, :section_id => "#{jsonmodel_type}_#{name}_" })
          end
        end
      end

      Plugins.sections_for(record, :readonly).each do |sub_record|
        result << sub_record.render_readonly(self, record, context)
      end

      result.html_safe
    end

    def form_plugins_for(jsonmodel_type, context, object = nil)
      result = ''
      Plugins.plugins_for(jsonmodel_type).each do |plugin|
        parent = Plugins.parent_for(plugin, jsonmodel_type)

        # with the new comma separated list, we need to iterate over each
        # name, cardinality pair

        names = parent['name'].split(',')
        cardinalities = parent['cardinality'].split(',')

        # check that name and cardinality count match
        # if they do not, pop up a message
        if names.count != cardinalities.count
          puts "Names and Cardinalities for #{plugin} do not have the same number of entries!"
        end

        # iterate over names
        # if a cardinality entry exists for the name index, use that, otherwise, use the last cardinality entry
        names.each_with_index do |name, idx|
          cardinality = cardinalities[idx].nil? ? cardinalities.last : cardinalities[idx]
          result << render_aspace_partial(:partial => "shared/subrecord_form",
                            :locals => {:form => context, :name => name,
                            :cardinality => cardinality.intern, :plugin => true})
        end

      end
  
      Plugins.sections_for(object || context.obj, :edit).each do |sub_record|
        result << sub_record.render_edit(self, context.obj, context)
      end
  
      result.html_safe
    end

  end
end
