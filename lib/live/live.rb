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

  def self.set_ad_image_association(associations)
    result = YandexDirect::Live.request('AdImageAssociation', {'Action': 'Set', 'AdImageAssociations': associations})
  end

  def self.bind_images(models)
    upload_task_ids = models.pluck(:image_upload_task_id)
    if upload_task_ids.any?
      image_hashes = YandexDirect::Live.get_image_hash(upload_task_ids)
      associations = []
      image_hashes.each do |result|
        unless result['Status'] == 'Pending'
          model = models.find{|model| model.image_upload_task_id == result['AdImageUploadTaskID']}
          associations.push({'AdID': model.group_id, 'AdImageHash': result['AdImageHash']}) unless result['Status'] == 'Error'
        end
      end
      result = YandexDirect::Live.set_ad_image_association(associations) if associations.any?
      if result.present?
        image_hashes.each do |hash|
          unless hash['Status'] == 'Pending'
            model = models.find{|model| model.image_upload_task_id == hash['AdImageUploadTaskID']}
            model_result = result['ActionsResult'].find{|res| res.present? && res['AdID'].to_i == model.group_id}
            model.update_column(:image_upload_task_id, 0) if model_result.present? && model_result['Errors'].blank?
          end
        end
      end
    end
  end
end
