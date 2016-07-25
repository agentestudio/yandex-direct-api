module YandexDirect::Live
  def self.configuration
    YandexDirect.configuration
  end

  def self.request (method, params = {})
    body = {
      locale: configuration['locale'],
      token: configuration['token'],
      method: method,
      param: params
    }

    url = URI((configuration['sandbox'] ? 'https://api-sandbox.direct.yandex.ru/live/v4/json/' : 'https://api.direct.yandex.ru/live/v4/json/'))

    if configuration['verbose']
      puts "\t\033[32mYandex.Direct:\033[0m #{method}(#{body[:param]})"
    end

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = http.post(url.path, JSON.generate(body))

    raise YandexDirect::RuntimeError.new("#{response.code} - #{response.message}") unless response.code.to_i == 200

    json = YandexDirect.parse_json(response.body)
    
    if json.has_key?('error_code') and json.has_key?('error_str')
      code = json['error_code'].to_i
      error = json['error_detail'].length > 0 ? json['error_detail'] : json['error_str']
      raise YandexDirect::RuntimeError.new "#{code} - #{error}"
    end
    
    return json['data']
  end

  def self.upload_image (url, name)
    result = YandexDirect::Live.request('AdImage', {'Action': 'Upload', 'AdImageURLData': [{'Login': configuration['login'], 'URL': url, 'Name': name}]})
    result['ActionsResult'].first['AdImageUploadTaskID']
  end

  def self.get_image_hash(upload_task_ids)
    result = YandexDirect::Live.request('AdImage', {'Action': 'CheckUploadStatus', 'SelectionCriteria': {'AdImageUploadTaskIDS': upload_task_ids}})
    result["AdImageUploads"]
  end

  def self.get_uploaded_image_hashes(params)
    upload_task_ids = params.map{|p| p[:image_upload_task_id]}
    associations = []
    if upload_task_ids.any?
      image_hashes = YandexDirect::Live.get_image_hash(upload_task_ids)
      image_hashes.each do |result|
        unless result['Status'] == 'Pending'
          add = params.find{|p| p[:image_upload_task_id] == result['AdImageUploadTaskID']}
          associations.push({add_id: add[:add_id], ad_image_hash: result['AdImageHash']}) unless result['Status'] == 'Error'
        end
      end
    end
    associations
  end
end
