# ==========================================
# SYSTEM: Database Core Engine
# DESCRIPTION: Manages the PostgreSQL connection pool.
# ==========================================

require 'pg'
require 'time'
require 'connection_pool'

# Require all the modules
require_relative 'schema'
require_relative 'economy'
require_relative 'gacha'
require_relative 'leveling'
require_relative 'cooldowns'
require_relative 'social'
require_relative 'admin'

class PGPoolWrapper
  def initialize(url)
    @pool = ConnectionPool.new(size: 20, timeout: 5) { PG.connect(url) }
  end

  def exec(*args)
    @pool.with { |conn| conn.exec(*args) }
  end

  def exec_params(*args)
    @pool.with { |conn| conn.exec_params(*args) }
  end
end

class BotDatabase
  include DatabaseSchema
  include DatabaseEconomy
  include DatabaseGacha
  include DatabaseLeveling
  include DatabaseCooldowns
  include DatabaseSocial
  include DatabaseAdmin

  def initialize
    @db = PGPoolWrapper.new(ENV['DATABASE_URL'])
    setup_schema # Defined in schema.rb
  end
end

# The global instance used by the rest of the bot
DB = BotDatabase.new