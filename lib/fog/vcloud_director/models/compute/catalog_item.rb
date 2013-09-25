require 'fog/core/model'

module Fog
  module Compute
    class VcloudDirector

      class CatalogItem < Model

        identity  :id

        attribute :name
        attribute :type
        attribute :href
        attribute :description, :aliases => :Description
        attribute :entity, :aliases => :Entity

        def instantiate(vdc, vapp_name, options={})
          if network_config = options.delete(:network_config)
            network_config = [network_config] if network_config.is_a?(Hash)
            options[:network_config] = network_config.map do |config|
              network = config.delete(:network)
              config.merge!({
                :name => network.name,
                :href => network.href
              })
            end
          end
          response = service.instantiate_vapp_template(vdc.id, entity[:href], vapp_name, options)
          service.process_task(response.body[:Tasks][:Task])
        end

        def vapp_template_id  # DEPRECATED
          entity[:href].split('/').last
        end

      end
    end
  end
end
