ArchivesSpace::Application.extend_aspace_routes(File.join(File.dirname(__FILE__), "routes.rb"))
  
Rails.application.config.after_initialize do
  module PluginHelper

    def sidebar_plugins_for(record)
      result = ''
      jsonmodel_type = record['jsonmodel_type']
      Plugins.plugins_for(jsonmodel_type).each do |plugin|
        # addition
        # split on commas and check each name entry
        names = Plugins.parent_for(plugin, jsonmodel_type)['name'].gsub(/\s+/,'').split(',')
        names.each do |name|      
          if not controller.action_name === "show" or Array(record.send(name)).length > 0
            result << '<li>'
            result << "<a href='##{jsonmodel_type}_#{name}_'>"
            result << I18n.t("plugins.#{name}._plural", default: I18n.t("plugins.#{plugin}._plural"))
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
        names.gsub(/\s+/,'').split(',').each do |name|
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
        names = parent['name'].gsub(/\s+/,'').split(',')
        cardinalities = parent['cardinality'].gsub(/\s+/,'').split(',')

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
