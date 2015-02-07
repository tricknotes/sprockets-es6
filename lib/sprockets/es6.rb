require '6to5'
require 'sprockets'
require 'sprockets/es6/version'

module Sprockets
  class ES6
    def self.instance
      @instance ||= new
    end

    def self.call(input)
      instance.call(input)
    end

    def initialize(options = {})
      @options = options.dup.freeze

      @cache_key = [
        self.class.name,
        ES6to5.version,
        VERSION,
        @options
      ].freeze
    end

    def call(input)
      filename = File.basename(input[:name], '.*')
      data = input[:data]
      options = @options.reverse_merge(modules: 'amd', moduleIds: true, filename: filename)

      result = input[:cache].fetch(@cache_key + [data, options]) do
        ES6to5.transform(data, options)
      end
      result['code']
    end
  end

  append_path ES6to5::Source.root
  register_mime_type 'text/ecmascript-6', extensions: ['.es6'], charset: :unicode
  register_transformer 'text/ecmascript-6', 'application/javascript', ES6
  register_preprocessor 'text/ecmascript-6', DirectiveProcessor
end
