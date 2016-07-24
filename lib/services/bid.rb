class YandexDirect::Bid
  SERVICE = 'bids'

  def self.list(params)
    selection_criteria = {}
    selection_criteria["CampaignIds"] = params[:campaign_ids] if params[:campaign_ids].present?
    selection_criteria["Ids"] = params[:ids] if params[:ids].present?
    selection_criteria["AdGroupIds"] = params[:ad_group_ids] if params[:ad_group_ids].present?
    selection_criteria["KeywordIds"] = params[:keyword_ids] if params[:keyword_ids].present?
    YandexDirect.request(SERVICE, 'get', { 
      "SelectionCriteria": selection_criteria,
      "FieldNames": ["KeywordId", "AdGroupId", "CampaignId", "Bid", "ContextBid", "StrategyPriority", "CompetitorsBids", "SearchPrices", "ContextCoverage", "MinSearchPrice", "CurrentSearchPrice", "AuctionBids"]
    })["Bids"] || []
  end

  def self.set(bids)
    bids.map! do |bid|
      params = {"Bid": bid[:bid] * 1000000, "StrategyPriority": bid[:StrategyPriority] || "NORMAL"}
      params["CampaignId"] = bid[:campaign_id] if bid[:campaign_id].present?
      params["AdGroupId"] = bid[:ad_group_id] if bid[:ad_group_id].present?
      params["KeywordId"] = bid[:keyword_id] if bid[:keyword_id].present?
      params["ContextBid"] = bid[:context_bid] * 1000000 if bid[:context_bid].present?
      params
    end
    YandexDirect.request(SERVICE, 'set', {"Bids": bids})["SetResults"]
  end
end
