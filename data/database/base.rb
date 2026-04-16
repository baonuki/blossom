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
require_relative 'crews'

class PGPoolWrapper
  def initialize(url)
    @url = url
    @pool = ConnectionPool.new(size: 20, timeout: 5) { PG.connect(url) }
  end

  def exec(*args)
    with_retry { |conn| conn.exec(*args) }
  end

  def exec_params(*args)
    with_retry { |conn| conn.exec_params(*args) }
  end

  private

  def with_retry(&block)
    retries = 0
    @pool.with do |conn|
      begin
        conn.exec("SELECT 1") unless conn.status == PG::CONNECTION_OK
        block.call(conn)
      rescue PG::ConnectionBad, PG::UnableToSend => e
        retries += 1
        if retries <= 1
          conn.reset
          retry
        else
          raise e
        end
      end
    end
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
  include DatabaseCrews

  def initialize
    @db = PGPoolWrapper.new(ENV['DATABASE_URL'])
    setup_schema # Defined in schema.rb
  end
end

# The global instance used by the rest of the bot
DB = BotDatabase.new