# README

Testing app inspired in the blog

https://blog.appsignal.com/2020/12/02/building-a-multi-tenant-ruby-on-rails-app-with-subdomains.html

Add middleware to dinamically create databases for tenants

# Multi-Tenant Rails Application with Subdomains

## Objective

This application demonstrates a multi-tenant setup in a Ruby on Rails application using subdomains to isolate tenant data. Each tenant has its own SQLite database, which is dynamically created and migrated when a new tenant (author) is added to the system.

## Structure and Components

### Models

- **Author**: Represents a tenant in the system. When a new author is created, a corresponding database is dynamically created and migrated.

### Middleware

- **SubdomainDatabaseSwitcher**: A custom middleware that switches the database connection based on the subdomain of the incoming request. It ensures that each tenant's requests are handled in their respective databases.

### Dynamic Database Creation

- **DynamicDatabaseConnections**: A module that handles the creation and migration of new tenant databases dynamically when a new author is created.

## Implementation Details

### 1. Author Model

The `Author` model uses an `after_commit` callback to trigger the dynamic database creation process after the author record is successfully created and committed.

app/models/author.rb

## 2. Dynamic Database Connections

The DynamicDatabaseConnections module is responsible for dynamically adding a new database configuration, establishing the connection, and running migrations for the new database.

config/initializers/dynamic_database_connections.rb

## 3. Subdomain Middleware

The SubdomainDatabaseSwitcher middleware is responsible for switching the database connection based on the subdomain of the incoming request. It ensures that requests to different subdomains are routed to the correct tenant database.

app/middleware/subdomain_database_switcher.rb


## 4. Database Configuration

The config/database.yml file includes the configurations for the primary database and a placeholder for dynamically created tenant databases.

config/database.yml

## 5. Routes Configuration

The config/routes.rb file should be configured to handle subdomains. Ensure that your routes are set up to recognize subdomains and route requests accordingly.

config/routes.rb

## 6. Application Configuration

In the config/application.rb file, ensure that the middleware is loaded and configured to handle subdomains.

## 7. Environment Configuration

By default, Rails set the top-level domain length to 1, but we want to use localhost to set this setting to 0. We can do this by adding the following line to the file config/environments/development.rb
```ruby
config.action_dispatch.tld_length = 0
```

