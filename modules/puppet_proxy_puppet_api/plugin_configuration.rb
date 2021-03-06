module ::Proxy::PuppetApi
  class PluginConfiguration
    def load_programmable_settings(settings)
      settings[:classes_retriever] = :apiv3
      settings[:environments_retriever] = :apiv3
      settings
    end

    def load_classes
      require 'puppet_proxy_common/custom_validators'
      require 'puppet_proxy_common/errors'
      require 'puppet_proxy_common/environments_retriever_base'
      require 'puppet_proxy_common/environment'
      require 'puppet_proxy_common/puppet_class'
      require 'puppet_proxy_common/api_request'
      require 'puppet_proxy_puppet_api/v3_api_request'
      require 'puppet_proxy_puppet_api/v3_environments_retriever'
      require 'puppet_proxy_puppet_api/v3_classes_retriever'
    end

    def load_dependency_injection_wirings(container_instance, settings)
      container_instance.dependency :environment_retriever_impl,
                                    lambda {::Proxy::PuppetApi::V3EnvironmentsRetriever.new(settings[:puppet_url], settings[:puppet_ssl_ca], settings[:puppet_ssl_cert], settings[:puppet_ssl_key])}

      container_instance.dependency :class_retriever_impl,
                                    lambda {::Proxy::PuppetApi::V3ClassesRetriever.new(settings[:puppet_url], settings[:puppet_ssl_ca], settings[:puppet_ssl_cert], settings[:puppet_ssl_key])}

    end
  end
end
