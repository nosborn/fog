module Fog
  module Compute
    class VcloudDirector
      class Real

        # TODO move all the logic to a generator

        # Create a vApp from a vApp template.
        #
        # ==== Parameters
        # * vdc_id<~String> -
        # * template_href<~String> -
        # * vapp_name<~String> -
        # * options<~Hash>:
        #   * :name<~String> -
        #   * :deploy<~Boolean> - True if the vApp should be deployed at instantiation. Defaults to true.
        #   * :power_on<~Boolean> - True if the vApp should be powered-on at instantiation. Defaults to true.
        #   * :description<~String> - Optional description.
        #   * :network_config<~Array>: array of hashes
        #     * :name<~String> - The name of the vApp network.
        #     * :href<~String> - Contains reference to parent network.
        #     * :fence_mode<~String> - Isolation type of the network.
        #   * :is_source_delete<~Boolean> - Set to true to delete the source object after the operation completes.
        #   * :all_eulas_accepted<~Boolean> - True confirms acceptance of all EULAs in a vApp template. 
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #
        # {vCloud API Reference}[http://pubs.vmware.com/vcd-51/topic/com.vmware.vcloud.api.reference.doc_51/doc/operations/POST-InstantiateVAppTemplate.html]
        def instantiate_vapp_template(vdc_id, template_href, vapp_name, options={})
          body = generate_instantiate_vapp_template_params(
            template_href, vapp_name, options
          )
          request(
            :body    => body,
            :expects => 201,
            :headers => { 'Content-Type' => 'application/vnd.vmware.vcloud.instantiateVAppTemplateParams+xml' },
            :method  => 'POST',
            :parser  => Fog::ToHashDocument.new,
            :path    => "vdc/#{vdc_id}/action/instantiateVAppTemplate"
          )
        end

        def generate_instantiate_vapp_template_params(href, name, options={})
          attributes = xmlns
          attributes[:name] = name
          attributes[:deploy] = options[:deploy] if options.has_key?(:deploy)
          attributes[:power_on] = options[:power_on] if options.has_key?(:power_on)

          xm = Builder::XmlMarkup.new
          xm.InstantiateVAppTemplateParams(attributes) {
            if options.has_key?(:description)
              xm.Description(options[:description])
            end
            xm.InstantiationParams {
              if options.has_key?(:network_config)
                xm.NetworkConfigSection {
                  xm.tag!('ovf:Info') do
                    'Configuration parameters for logical networks'
                  end
                  options[:network_config].each do |network_config|
                    xm.NetworkConfig(:networkName => network_config[:name]) {
                      xm.Configuration {
                        xm.ParentNetwork(:href => network_config[:href])
                        if network_config.has_key?(:fence_mode)
                          xm.FenceMode(network_config[:fence_mode]) #|| 'bridged')
                        end
                      }
                    }
                  end
                }
              end
            }
            xm.Source(:href => href)
            if options.has_key?(:is_source_delete)
              xm.IsSourceDelete(options[:is_source_delete])
            end
            if options.has_key?(:all_eulas_accepted)
              xm.AllEULAsAccepted(options[:all_eulas_accepted])
            end
          }
        rescue Excon::Errors::BadRequest => e
          raise
        end

        private

        def xmlns
          {
            'xmlns'     => 'http://www.vmware.com/vcloud/v1.5',
            "xmlns:ovf" => 'http://schemas.dmtf.org/ovf/envelope/1',
          }
        end

      end
    end
  end
end
