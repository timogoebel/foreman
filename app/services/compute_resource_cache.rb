# This class caches attributes for a compute resource in
# rails cache to speed up slow or expensive API calls
class ComputeResourceCache
  attr_accessor :compute_resource

  def initialize(compute_resource, opts)
    self.compute_resource = compute_resource
    self.cache_duration = opts.fetch(:cache_duration, 180.minutes)
  end

  # Tries to retrieve the value for a given key from the cache
  # and returns the retrieved value. If the cache is empty,
  # the given block is executed and the block's return stored
  # in the cache. This value is then returned by this method.
  def cache(key, &block)
    cached_value = fetch(key)
    return cached_value if cached_value
    return unless block_given?
    uncached_value = compute_resource.instance_eval(&block)
    store(uncached_value)
    uncached_value
  end

  def delete(key)
    Rails.cache.delete(cache_key + key)
  end

  def retrieve(key)
    Rails.cache.fetch(cache_key + key)
  end

  def store(key, value)
    Rails.cache.write(cache_key + key, value)
  end

  private

  def cache_key
    "compute_resource_#{compute_resource.id}/"
  end
end
