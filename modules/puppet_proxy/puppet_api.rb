class Proxy::Puppet::Api < ::Sinatra::Base
  extend Proxy::Puppet::DependencyInjection
  helpers ::Proxy::Helpers

  authorize_with_trusted_hosts
  authorize_with_ssl_client

  inject_attr :class_retriever_impl, :class_retriever
  inject_attr :environment_retriever_impl, :environment_retriever
  inject_attr :puppet_runner_impl, :puppet_runner

  post "/run" do
    begin
      log_halt 400, "Failed puppet run: No nodes defined" unless params[:nodes]
      log_halt 500, "Failed puppet run: Check Log files" unless puppet_runner.run([params[:nodes]].flatten)
    rescue => e
      log_halt 500, "Failed puppet run: #{e}"
    end
  end

  get "/environments" do
    content_type :json
    begin
      environment_retriever.all.map(&:name).to_json
    rescue => e
      log_halt 406, "Failed to list puppet environments: #{e}" # FIXME: replace 406 with status codes from http response
    end
  end

  get "/environments/:environment" do
    content_type :json
    begin
      env = environment_retriever.get(params[:environment])
      {:name => env.name, :paths => env.paths}.to_json
    rescue Proxy::Puppet::EnvironmentNotFound
      log_halt 404, "Could not find environment '#{params[:environment]}'"
    rescue => e
      log_halt 406, "Failed to show puppet environment: #{e}" # FIXME: replace 406 with appropriate status codes
    end
  end

  get "/environments/:environment/classes" do
    content_type :json
    begin
      class_retriever.classes_in_environment(params[:environment]).map{|k| {k.to_s => { :name => k.name, :module => k.module, :params => k.params} } }.to_json
    rescue Proxy::Puppet::EnvironmentNotFound
      log_halt 404, "Could not find environment '#{params[:environment]}'"
    rescue Exception => e
      log_halt 406, "Failed to show puppet classes: #{e}"
    end
  end
end
