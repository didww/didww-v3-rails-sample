class ResourceDecorator < ApplicationDecorator
  def self.object_class_name
    "DIDWW::Resource::#{name.chomp('Decorator')}"
  end

  def self.collection_decorator_name
    'ResourceCollectionDecorator'
  end

  private

  def format_time(time)
    Time.parse(time).strftime('%F %T %Z')
  end
end
