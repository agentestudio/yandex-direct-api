require 'yaml'

namespace :yandex_direct_api do
  desc "Create yandex-direct-api configuration file"
  task install: :environment do
    File.open(Rails.root.join('config', 'yandex_direct_api.yml'), 'w') do |config| 
      settings = {'development' => {'token' => '', 'login' => '', 'locale' => 'ru', 'verbose' => true, 'sandbox' => true}, 
                  'test' => {'token' => '', 'login' => '', 'locale' => 'ru', 'verbose' => 'false', 'sandbox' => true}, 
                  'production' => {'token' => '', 'login' => '', 'locale' => 'ru', 'verbose' => false, 'sandbox' => false}}
      config.write(settings.to_yaml)
    end
    File.open(Rails.root.join('config', 'initializers', 'yandex_direct_api.rb'), 'w') do |config| 
      config.write "require 'yandex_direct_api'\nYandexDirect.load File.join(Rails.root, 'config','yandex_direct_api.yml'), Rails.env"
    end
  end
end
