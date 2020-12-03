class Gratan::DSL::Context::On
  include Gratan::DSL::Validator
  include Gratan::TemplateHelper

  attr_reader :result

  def initialize(context, user, host, object, options, &block)
    @object_identifier = "User `#{user}@#{host}` on `#{object}`"
    @user = user
    @host = host
    @object = object
    @options = options
    @context = context.merge(:object => object, :grant_options => options)
    @result = []
    instance_eval(&block)
  end

  def grant(name, options = {})
    __validate("Grant `#{name}` is already defined") do
      not @result.include?(name)
    end

    @result << name
  end
end
