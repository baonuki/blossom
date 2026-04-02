# ==========================================
# HELPER: In-Memory TTL Cache
# DESCRIPTION: Reduces database calls by caching frequently
# read, rarely written data with automatic expiry.
# ==========================================

class BlossomCache
  def initialize
    @store = {}
    @mutex = Mutex.new
  end

  # Get a value from cache. Returns nil if expired or missing.
  def get(namespace, key)
    full_key = "#{namespace}:#{key}"
    @mutex.synchronize do
      entry = @store[full_key]
      return nil unless entry
      if Time.now > entry[:expires]
        @store.delete(full_key)
        return nil
      end
      entry[:value]
    end
  end

  # Set a value with TTL in seconds.
  def set(namespace, key, value, ttl:)
    full_key = "#{namespace}:#{key}"
    @mutex.synchronize do
      @store[full_key] = { value: value, expires: Time.now + ttl }
    end
    value
  end

  # Invalidate a specific key.
  def invalidate(namespace, key)
    full_key = "#{namespace}:#{key}"
    @mutex.synchronize { @store.delete(full_key) }
  end

  # Invalidate all keys in a namespace (e.g., all "premium" entries).
  def invalidate_namespace(namespace)
    prefix = "#{namespace}:"
    @mutex.synchronize do
      @store.delete_if { |k, _| k.start_with?(prefix) }
    end
  end

  # Invalidate everything.
  def flush!
    @mutex.synchronize { @store.clear }
  end

  # Get-or-set pattern: returns cached value or executes block and caches result.
  def fetch(namespace, key, ttl:, &block)
    cached = get(namespace, key)
    return cached unless cached.nil?
    value = block.call
    set(namespace, key, value, ttl: ttl)
    value
  end

  # Stats for debugging
  def size
    @mutex.synchronize { @store.size }
  end

  def stats
    now = Time.now
    @mutex.synchronize do
      active = @store.count { |_, v| v[:expires] > now }
      expired = @store.size - active
      { total: @store.size, active: active, expired: expired }
    end
  end
end

# Global cache instance
CACHE = BlossomCache.new

# TTL constants (in seconds)
CACHE_TTL_PREMIUM    = 300  # 5 minutes
CACHE_TTL_COSMETICS  = 120  # 2 minutes
CACHE_TTL_PROFILE    = 120  # 2 minutes
CACHE_TTL_INVENTORY  = 60   # 1 minute
CACHE_TTL_SERVER_CFG = 600  # 10 minutes
