ArchivesSpace Multiple Subrecords
=====================================

## Note
This plugin is a proof of concept to see if we can modify core to allow
plugins to define multiple subrecords.

It allows a plugin to define multiple subrecords - specifically in the 
`config.yml` file. It assumes that multiple entries are comman separated
and.

### Example config

```
repository_menu_controller: multi_hello_world_ones, multi_hello_world_twos
no_automatic_routes: true
parents:
     accession:
          name: multi_hello_world_ones, multi_hello_world_twos
          cardinality: zero_to_many, zero_to_many
archival_object:
          name: multi_hello_world_ones, multi_hello_world_twos
          cardinality: zero_to_many, zero_to_many
resource:
          name: multi_hello_world_ones, multi_hello_world_twos
          cardinality: zero_to_many
digital_object:
          name: multi_hello_world_ones
          cardinality: zero_to_many
digital_object_component:
          name: multi_hello_world_twos
          cardinality: zero_to_many, zero_to_many
```

## Getting started

This plugin has been tested with ArchivesSpace versions 3.3.1+, but should work 
for v3.1.1 forward.

Unzip the latest release of the plugin to your
ArchivesSpace plugins directory:

     $ cd /path/to/archivesspace/plugins
     $ unzip multiple_subrecords.zip -d multiple_subrecords

Enable the plugin by editing your ArchivesSpace configuration file
(`config/config.rb`):

     AppConfig[:plugins] = ['other_plugin', 'multiple_subrecords']

(Make sure you uncomment this line (i.e., remove the leading '#' if present))

See also:

  https://github.com/archivesspace/archivesspace/blob/master/plugins/README.md

You will need to shut down ArchivesSpace and migrate the database:

     $ cd /path/to/archivesspace
     $ scripts/setup-database.sh

See also:

  https://github.com/archivesspace/archivesspace/blob/master/UPGRADING.md

This will create the tables required by the plugin.

## Core Overrides

You will need to place the following code block in  your config file *before* `AppConfig[:plugins]`

```
module Plugins

     def self.init
     @config = {:system_menu_items => [], :repository_menu_items => [], :plugin => {}, :parents => {}}
     Array(AppConfig[:plugins]).each do |plugin|
          # config.yml is optional, so defaults go here
          @config[:plugin][plugin] = {'parents' => []}
          plugin_dir = ASUtils.find_local_directories(nil, plugin).shift

          config_path = File.join(plugin_dir, 'config.yml')
          if File.exist?(config_path)
          @config[:plugin][plugin] = cfg = YAML.load_file config_path
          
          # Addition: split the config entries for system and repo menu items
          @config[:system_menu_items].concat(cfg['system_menu_controller'].gsub(/\s+/,'').split(',')) if cfg['system_menu_controller']
          @config[:repository_menu_items].concat(cfg['repository_menu_controller'].gsub(/\s+/,'').split(',')) if cfg['repository_menu_controller']

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
```

See `frontend/plugin_init.rb` for overrides to `PluginHelper` methods

## Credits

Plugin developed by Joshua Shaw [Joshua.D.Shaw@dartmouth.edu], Digital Library Technologies Group
Dartmouth Library, Dartmouth College
