# config/initializers/dynamic_database_connections.rb
module DynamicDatabaseConnections
  def self.add_connection_for(author)
    subdomain = author.slug
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

    begin
      # Establish connection to the new database (this will create the database file if it doesn't exist)
      ActiveRecord::Base.establish_connection("primary_#{subdomain}".to_sym)

      # Run migrations for the new database
      Rails.application.load_tasks
      Rake::Task["db:migrate"].reenable # Ensure the task can be invoked multiple times
      Rake::Task["db:migrate"].invoke

      Rails.logger.info "Successfully created and migrated database for #{subdomain}"
    rescue StandardError => e
      Rails.logger.error "Failed to create or migrate database for #{subdomain}: #{e.message}"
      # Ensure to rollback the author creation in case of failure
      author.destroy
      raise e
    ensure
      # Reset to primary connection
      ActiveRecord::Base.establish_connection(:primary)
    end
  end
end
