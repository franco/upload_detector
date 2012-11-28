require 'pstore'
class ImportStore

  module StoreMethods
    attr_accessor :_store
    def save
      _store.transaction do
        _store[self.id] = self.to_params
      end
    end
  end

  def initialize args={}
    @location = args[:location] || 'imports.pstore'
  end

  def find id
    attrs = nil
    store.transaction(true) do
      attrs = store[id]
    end
    attrs ? create_import(attrs) : nil
  end

  def create_import attrs
    import = Import.new attrs
    import.extend StoreMethods
    import._store = store
    import.save
    import
  end

  def find_or_create_import attrs
    find(attrs[:upload_reference]) or create_import(attrs)
  end

  def each
    store.transaction(true) do
      store.roots.each do |id|
        yield store[id]
      end
    end
  end

  def list_imports
    each do |import_attrs|
      p import_attrs
    end
  end

  private

  def init_store
    thread_safe = true
    ultra_safe  = true
    store = PStore.new(@location, thread_safe)
    store.ultra_safe = ultra_safe
    store
  end

  def store
    @store ||= init_store
  end


end
