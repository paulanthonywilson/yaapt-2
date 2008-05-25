module Contentful
  if !Contentful.const_defined?(:VERSION)
    VERSION = 0.82
    BASE_DIRECTORY = File.join(RAILS_ROOT, 'test', 'contentful')
  end
end
