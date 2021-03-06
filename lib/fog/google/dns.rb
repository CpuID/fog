require 'fog/google/core'

module Fog
  module DNS
    class Google < Fog::Service
      requires :google_project
      recognizes :app_name, :app_version, :google_client_email, :google_key_location, :google_key_string, :google_client

      GOOGLE_DNS_API_VERSION     = 'v1beta1'
      GOOGLE_DNS_BASE_URL        = 'https://www.googleapis.com/dns/'
      GOOGLE_DNS_API_SCOPE_URLS  = %w(https://www.googleapis.com/auth/ndev.clouddns.readwrite)

      request_path 'fog/google/requests/dns'
      request :create_managed_zone
      request :delete_managed_zone
      request :get_managed_zone
      request :list_managed_zones

      class Mock
	include Fog::Google::Shared

        def initialize(options)
          shared_initialize(options[:google_project], GOOGLE_DNS_API_VERSION, GOOGLE_DNS_BASE_URL)
        end

	def self.data(api_version)
	  @data ||= {}
	end

	def self.reset
	  @data = nil
	end

        def data(project=@project)
          self.class.data(api_version)[project] ||= {
              :managed_zones => {
                  :by_id => {},
                  :by_name => {},
              },
	  }
        end

        def reset_data
          self.class.data(api_version).delete(@project)
        end
      end

      class Real
        include Fog::Google::Shared

        attr_accessor :client
        attr_reader :dns

        def initialize(options)
          shared_initialize(options[:google_project], GOOGLE_DNS_API_VERSION, GOOGLE_DNS_BASE_URL)
          options.merge!(:google_api_scope_url => GOOGLE_DNS_API_SCOPE_URLS.join(' '))
          @client = initialize_google_client(options)
          @dns = @client.discovered_api('dns', api_version)
        end
      end
    end
  end
end
