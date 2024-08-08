class Author < ApplicationRecord
  validates_uniqueness_of :slug, on: [:create, :update], message: "must be unique"
  after_commit :add_dynamic_database_connection, on: :create

  private

  def add_dynamic_database_connection
    DynamicDatabaseConnections.add_connection_for(self)
  end
end
