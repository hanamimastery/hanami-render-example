# frozen_string_literal: true

Hanami.app.register_provider :persistence, namespace: true do
  prepare do
    require "rom-changeset"
    require "rom/core"
    require "rom/sql"

    configuration = ROM::Configuration.new :sql, target["settings"].database_url

    configuration.plugin :sql, relations: :instrumentation do |plugin_config|
      plugin_config.notifications = target["notifications"]
    end

    configuration.plugin :sql, relations: :auto_restrictions

    register "config", configuration
    register "db", configuration.gateways[:default].connection
  end

  start do
    configuration = target["persistence.config"]
    configuration.auto_registration(
      target.root.join("lib/hanamimastery/persistence"),
      namespace: "Hanamimastery::Persistence"
    )

    register "rom", ROM.container(configuration)
  end
end
