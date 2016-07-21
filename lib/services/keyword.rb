class YandexDirect::Keyword
  SERVICE = 'keywords'

  def self.add(params)
    words = params[:words]
    ad_group_id = params[:ad_group_id]
    keywords = words.map do |word|
      { "Keyword": word[:word],
        "AdGroupId": ad_group_id,
        "Bid": word[:bid],
        "ContextBid": word[:context_bid],
        "StrategyPriority": word[:strategy_priority] || "NORMAL"
      }
    end
    YandexDirect.request(SERVICE, 'add', {"Keywords": keywords})["AddResults"]
  end

  def self.list(params)
    selection_criteria = {"States":  ["ON"], "Statuses": ["ACCEPTED", "DRAFT"]}
    selection_criteria["CampaignIds"] = params[:campaign_ids] if params[:campaign_ids].present?
    selection_criteria["Ids"] = params[:ids] if params[:ids].present?
    selection_criteria["AdGroupIds"] = params[:ad_group_ids] if params[:ad_group_ids].present?
    YandexDirect.request(SERVICE, 'get', { 
      "SelectionCriteria": selection_criteria,
      "FieldNames": ["Id", "Keyword", "State", "Status", "AdGroupId", "CampaignId", "Bid", "ContextBid"]
    })["Keywords"]
  end

  def self.update(keywords)
    keywords.map! do |word|
      { "Id": word[:id],
        "Keyword": word[:word]
      }
    end
    YandexDirect.request(SERVICE, 'update', {"Keywords": keywords})["AddResults"]
  end
end
