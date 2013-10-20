require 'json'
require "syncshare/version"

module Syncshare
  require 'amqp'

  class Module
    attr_accessor :options

    def self.register(params, &block)
      instance = self.new
      options  = { :host => "localhost" }

      [:service, :host].each do |key|
        options[key] = params[key] if params.include? (key)
      end

      instance.options = options

      # run event machinery
      instance.activate(DSL.new(block))
      
    end

    def activate(dsl)
      EventMachine.run do
        service = @options[:service]
        connection = AMQP.connect(:host => @options[:host])
        channel = AMQP::Channel.new(connection)

        puts "Connecting to AMQP broker at #{@options[:host]}[service=#{service}]. Running #{AMQP::VERSION} version of the gem..."

        dsl.exchange_public = channel.fanout(service + "-public")
        dsl.exchange_direct = channel.topic(service + "-direct")

        dsl.callers.keys.each do |key|
          channel.queue(service + ".direct-" + key.to_s).bind(dsl.exchange_direct, :routing_key => key).subscribe do |header, payload|
            token, data = payload.split('|')

            proc = dsl.callers[key]
            proc.call({:token => token, :data => data ? JSON.parse(data) : {}}, header) unless proc.nil?
          end
        end
      end
    end
    
    class DSL
      attr_reader :callers
      attr_accessor :exchange_public, :exchange_direct
                 
      def initialize(block)
        @callers = {}
        instance_eval(&block)
      end
      
      def message(name, &block)
        @callers[name] = block
      end

      def reply(type, response, header)
        case type
        when :direct then exchange_direct.publish(response.to_json,
                                                  :routing_key => header.reply_to,
                                                  :correlation_id => header.correlation_id,
                                                  :headers => {:type => "message"})
        when :public then exchange_public.publish(response.to_json,
                                                  :correlation_id => header.correlation_id,
                                                  :headers => {:type => "broadcast"})
        end
      end
    end
  end
end
