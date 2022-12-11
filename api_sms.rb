class ApiSms
  require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  ruby '3.0.2'

  gem 'httparty'
  gem 'twilio-ruby'
  gem 'pry'
  gem 'actionview'
  gem 'dotenv'
end

require 'dotenv/load'
require 'pry'
require 'httparty'
require 'action_view'
require 'twilio-ruby'

include HTTParty
  include ActionView::Helpers::NumberHelper

  attr_accessor :workers_online, :hashrate
  def initialize()
    @workers_online = 0
    @hashrate = 0
    initialize_twilio_info
  end


  def initialize_twilio_info
    @account_sid = ENV["ACCT_SID"]
    @auth_token = ENV["AUTH_TOKEN"]
    @client = Twilio::REST::Client.new(@account_sid, @auth_token)
  end

  def run
    get_ckpoool_info
    send_sms
  end

  private
    def get_ckpoool_info
      response = JSON.parse(HTTParty.get("https://solo.ckpool.org/users/#{ENV['Wallet']}").parsed_response)
      self.hashrate = response['hashrate1m'] + 'H'
      self.workers_online = response['workers']
    end

    def send_sms
      if self.workers_online > 0
        client = Twilio::REST::Client.new(ENV["ACCT_SID"], ENV["AUTH_TOKEN"])
        client.messages.create(from: ENV["FROM"], to: ENV["TO"], body: " CkPool:\nHashrate: #{self.hashrate}\nWorkers Online: #{workers_online}")
      end
    end

end

ApiSms.new.run
