require 'fog/core/model'

module Fog
  module Compute
    class VcloudDirector

      class VmNetwork < Fog::Model

        identity  :id

        attribute :type
        attribute :href
        attribute :primary_network_connection_index, :type => :integer
        attribute :network_connections,              :type => :array

        def primary_network_connection
          network_connections[primary_network_connection_index]
        end

        def save
          response = service.put_vm_network(id, attributes)
          service.process_task(response.body)
        end

        # Convenience methods for working with VMs that have only a single
        # network connection.

        def network
          primary_network_connection[:network]
        end
        def network=(value)
          primary_network_connection[:network] = value
        end

        def needs_customization
          primary_network_connection[:needs_customization]
        end
        def needs_customization=(value)
          primary_network_connection[:needs_customization] = value
        end

        #attribute :network_connection_index

        def is_connected
          primary_network_connection[:is_connected]
        end
        def is_connected=(value)
          primary_network_connection[:is_connected] = value
        end

        def mac_address
          primary_network_connection[:mac_address]
        end
        def mac_address=(value)
          primary_network_connection[:mac_address] = value
        end

        def ip_address_allocation_mode
          primary_network_connection[:ip_address_allocation_mode]
        end
        def ip_address_allocation_mode=(value)
          primary_network_connection[:ip_address_allocation_mode] = value
        end

        def ip_address
          primary_network_connection[:ip_address]
        end
        def ip_address=(value)
          primary_network_connection[:ip_address] = value
        end

      end
    end
  end
end
