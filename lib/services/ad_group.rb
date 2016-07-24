class YandexDirect::AdGroup
  SERVICE = 'adgroups'
  attr_accessor :name, :campaign_id, :id, :status, :region_ids, :negative_keywords, :tracking_params

  def initialize(params)
    @name = params[:name]
    @id = params[:id]
    @status = params[:status]
    @campaign_id = params[:campaign_id]
    @region_ids = params[:region_ids]
    @negative_keywords = {"Items": params[:negative_keywords]} if params[:negative_keywords].present?
    @tracking_params = params[:tracking_params]
  end

  def self.list(params)
    selection_criteria = {"Types":  ["TEXT_AD_GROUP"]}
    selection_criteria["CampaignIds"] = params[:campaign_ids] if params[:campaign_ids].present?
    selection_criteria["Ids"] = params[:ids] if params[:ids].present?
    ad_groups = YandexDirect.request(SERVICE, 'get', { 
      "SelectionCriteria": selection_criteria,
      "FieldNames": ['Id', 'Name', 'CampaignId', 'Status', 'RegionIds', 'TrackingParams', 'NegativeKeywords']
    })["AdGroups"]
    (ad_groups || []).map{|c| new({ name: c["Name"], id: c["Id"], status: c["Status"], campaign_id: c["CampaignId"], 
                                    region_ids: c["RegionIds"], tracking_params: c["TrackingParams"], negative_keywords: c["NegativeKeywords"]})}
  end

  def self.add(params)
    if params.kind_of?(Array)
      batch_add(params)
    else
      params.id = YandexDirect.request(SERVICE, 'add', {"AdGroups": [params.parameters]})["AddResults"].first["Id"]
      params
    end
  end

  def self.update(params)
    if params.kind_of?(Array)
      batch_update(params)
    else
      params.id = YandexDirect.request(SERVICE, 'update', {"AdGroups": [params.update_parameters]})["UpdateResults"].first["Id"]
      params
    end
  end

  def parameters
    hash = {"Name": @name,
            "CampaignId": @campaign_id,
            "RegionIds": @region_ids || [0],
            "TrackingParams": @tracking_params
          }
    hash["NegativeKeywords"] = @negative_keywords if @negative_keywords.present?
    hash
  end

  def update_parameters
    hash = {"Name": @name,
            "RegionIds": @region_ids || [0],
            "TrackingParams": @tracking_params,
            "Id": @id
          }
    hash["NegativeKeywords"] = @negative_keywords if @negative_keywords.present?
    hash
  end

  private

  def self.batch_update(ad_groups)
    params = ad_groups.map(&:update_parameters)
    params.each_slice(100) do |add_parameters|
      YandexDirect.request(SERVICE, 'update', {"AdGroups": add_parameters.compact})["UpdateResults"]
    end
  end

  def self.batch_add(ad_groups)
    params = ad_groups.map(&:parameters)
    params.each_slice(100) do |add_parameters|
      YandexDirect.request(SERVICE, 'add', {"AdGroups": add_parameters.compact})["AddResults"]
    end
  end
end
