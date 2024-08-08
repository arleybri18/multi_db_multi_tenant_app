class SubdomainDatabaseSwitcher
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    host = request.host

    # Extract subdomain
    subdomain = extract_subdomain(host)

    # Connect to the primary database first
    ActiveRecord::Base.establish_connection(:primary)

    if subdomain.present?
      author = Author.find_by(slug: subdomain)
      if author
        # Establish a connection to the subdomain's database if the author is found

        new_db_name = "db/#{subdomain}_dev_multitenant_app.sqlite3"

        new_config = {
          adapter: "sqlite3",
          pool: (ENV["RAILS_MAX_THREADS"] || 5).to_i,
          timeout: 5000,
          database: new_db_name,
          migrations_paths: "db/tenants_migrations"
        }

        # Create a new HashConfig object
        new_config_obj = ActiveRecord::DatabaseConfigurations::HashConfig.new(Rails.env, "primary_#{subdomain}", new_config)

        # Add the new configuration to the existing configurations
        ActiveRecord::Base.configurations.configurations << new_config_obj
        
        ActiveRecord::Base.establish_connection("primary_#{subdomain}".to_sym)
      end
    end

    @app.call(env)
  ensure
    # Ensure the connection is reset to the primary database after the request
    ActiveRecord::Base.establish_connection(:primary)
  end

  private

  def extract_subdomain(host)
    # Assuming your app is running locally and using localhost with subdomains
    # e.g., johndoe.localhost:3000
    parts = host.split('.')
    return '' if parts.length < 2 # No subdomain

    parts[0] # Return the first part as the subdomain
  end
end
