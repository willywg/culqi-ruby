require 'util/connect'
require 'util/encrypt-data'
require 'util/validation/token'
require 'util/validation/charge'
require 'util/validation/customer'
require 'util/validation/refund'
require 'util/validation/plan'
require 'util/validation/card'
require 'util/validation/subscription'
require 'util/validation/order'

module Culqi::Post

  def initialize
    @url = ''
  end

  def create(params={}, rsa_key='', rsa_id='', custom_headers = nil)
    key = ''
    puts params
    error = verifyClassValidation(@url, params)
    if error
      return error
    end
    if @url.include?('charge') && rsa_key != ''
      params = Encrypt.encrypt_with_aes_rsa(params, rsa_key, true)
      key = Culqi.secret_key 
      response, statuscode = Culqi.connect(@url, key, params, 'post', Culqi::READ_TIMEOUT, false, rsa_id, custom_headers)
      return response, statuscode
    end
    if @url.include? 'token'
      if(rsa_key != '')
        params = Encrypt.encrypt_with_aes_rsa(params, rsa_key, true)
      end
      key = Culqi.public_key 
      response, statuscode = Culqi.connect(@url, key, params, 'post', Culqi::READ_TIMEOUT, true, rsa_id, custom_headers)
      return response, statuscode
    else
      key = Culqi.secret_key
      if @url.include?('plans') || @url.include?('subscriptions')
        response, statuscode = Culqi.connect(@url + 'create', key, params, 'post', Culqi::READ_TIMEOUT, false, '')
        return response, statuscode
      end

      response, statuscode = Culqi.connect(@url, key, params, 'post', Culqi::READ_TIMEOUT, false, '', custom_headers)
      return response, statuscode
    end
    
  end

  def verifyClassValidation(url='', params)
    begin
      if @url.include? 'token'
        TokenValidation.create(params)
      end

      if @url.include? 'charge'
        ChargeValidation.create(params)
      end
      
      if @url.include? 'card'
        CardValidation.create(params)
      end
      
      if @url.include? 'customer'
        CustomerValidation.create(params)
      end
      
      if @url.include? 'refund'
        RefundValidation.create(params)
      end
      
      if @url.include? 'plan'
        PlanValidation.create(params)
      end
      
      if @url.include? 'subscription'
        SubscriptionValidation.create(params)
      end
      
      if @url.include? 'order'
        OrderValidation.create(params)
      end
    rescue CustomException => e
      return e.message
    end
  end

end
