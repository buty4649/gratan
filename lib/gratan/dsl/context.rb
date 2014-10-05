class Gratan::DSL::Context
  include Gratan::DSL::Validator
  include Gratan::Logger::Helper

  def self.eval(dsl, path, options = {})
    self.new(path, options) do
      eval(dsl, binding, path)
    end
  end

  attr_reader :result

  def initialize(path, options = {}, &block)
    @path = path
    @options = options
    @result = {}
    instance_eval(&block)
  end

  private

  def require(file)
    grantfile = (file =~ %r|\A/|) ? file : File.expand_path(File.join(File.dirname(@path), file))

    if File.exist?(grantfile)
      instance_eval(File.read(grantfile), grantfile)
    elsif File.exist?(grantfile + '.rb')
      instance_eval(File.read(grantfile + '.rb'), grantfile + '.rb')
    else
      Kernel.require(file)
    end
  end

  def user(name, host, options = {}, &block)
    name = name.to_s
    host = host.to_s
    options ||= {}

    __validate("User `#{name}@#{host}` is already defined") do
      not @result.has_key?([name, host])
    end

    if @options[:enable_expired] and (expired = options.delete(:expired))
      expired = Time.parse(expired)

      if Time.new >= expired
        log(:warn, "User `#{name}@#{host}` has expired", :yellow)
        return
      end
    end

    @result[[name, host]] = {
      :objects => Gratan::DSL::Context::User.new(name, host, &block).result,
      :options => options,
    }
  end
end
