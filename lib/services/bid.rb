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
    bids = bids.select{|bid| bid[:bid].present?}.map do |bid|
      params = {"Bid": bid[:bid] * 1000000, "StrategyPriority": bid[:StrategyPriority] || "NORMAL"}
      %w(CampaignId AdGroupId KeywordId).each do |key| 
        params[key] = bid[key.underscore.to_sym] if bid[key.underscore.to_sym].present?
      end
      params["ContextBid"] = bid[:context_bid] * 1000000 if bid[:context_bid].present?
      params
    end
    bids.any? ? YandexDirect.request(SERVICE, 'set', {"Bids": bids})["SetResults"] : []
  end
end
