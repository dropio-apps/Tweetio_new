# Author      : William Richerd P
# Designation : Senior Software Engineer
# Create at   : 25th April, 2010
# Features    : Configuration for Drop.io

class User < TwitterAuth::GenericUser
  require "parseconfig"
  # Configured Drop.io user's API
  def self.dropio_config
    my_config = ParseConfig.new('config/application.yml')
    dropio_api = my_config.get_value('dropio_api')
    Dropio::Config.api_key = dropio_api
    Dropio::Config.debug = true
  end  
end