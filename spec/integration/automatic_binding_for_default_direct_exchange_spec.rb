# encoding: utf-8

require 'spec_helper'

describe "Queue that was bound to default direct exchange thanks to Automatic Mode (section 2.1.2.4 in AMQP 0.9.1 spec" do

  #
  # Environment
  #

  include AMQP::Spec

  default_timeout 10

  amqp_before do
    @channel   = MQ.new

    @queue1    = @channel.queue("queue1")
    @queue2    = @channel.queue("queue2")

    # Rely on default direct exchange binding, see section 2.1.2.4 Automatic Mode in AMQP 0.9.1 spec.
    @exchange = MQ::Exchange.default
  end



  #
  # Examples
  #

  it "receives messages with routing key equals it's name" do
    number_of_received_messages = 0
    expected_number_of_messages = 3
    dispatched_data             = "to be received by queue1"

    @queue1.subscribe do |payload|
      number_of_received_messages += 1
      payload.should == dispatched_data

      if number_of_received_messages == expected_number_of_messages
        $stdout.puts "Got all the messages I expected, wrapping up..."
        done
      else
        n = expected_number_of_messages - number_of_received_messages
        $stdout.puts "Still waiting for #{n} more message(s)"
      end
    end # subscribe

    4.times do
      @exchange.publish("some white noise", :routing_key => "killa key")
    end

    expected_number_of_messages.times do
      @exchange.publish(dispatched_data,    :routing_key => @queue1.name)    
    end

    4.times do
      @exchange.publish("some white noise", :routing_key => "killa key")
    end
  end # it
end # describe