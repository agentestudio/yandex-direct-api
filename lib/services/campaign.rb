class YandexDirect::Campaign
  SERVICE = 'campaigns'
  attr_accessor :name, :start_date, :time_zone, :id, :status, :state, :negative_keywords, :email, :owner_name, 
                :search_strategy, :network_strategy, :limit_percent, :bid_percent, :end_date, :daily_budget_amount,
                :daily_budget_mode, :blocked_ips, :excluded_sites, :type, :target_hours

  def initialize(params)
    @name = params[:name]
    @id = params[:id]
    @status = params[:status]
    @state = params[:state]
    @start_date = params[:start_date]
    @time_zone = params[:time_zone]
    @negative_keywords = {"Items": params[:negative_keywords]} if params[:negative_keywords].present?
    @email = params[:email]
    @owner_name = params[:owner_name]
    @limit_percent = params[:limit_percent]
    @bid_percent = params[:bid_percent]
    @end_date = params[:end_date]
    @daily_budget_amount = params[:daily_budget_amount]
    @daily_budget_mode = params[:daily_budget_mode]
    @blocked_ips = params[:blocked_ips]
    @excluded_sites = params[:excluded_sites]
    @search_strategy = params[:search_strategy]
    @network_strategy = params[:network_strategy]
    @target_hours = params[:target_hours]
    @type == params[:type] || "TEXT_CAMPAIGN"
  end

  def self.list
    YandexDirect.request(SERVICE, 'get', { 
      "SelectionCriteria": {
        "Types": ["TEXT_CAMPAIGN"], 
        "States": ["OFF", "ON"], 
        "Statuses": ["ACCEPTED", "DRAFT", "MODERATION"]
      },
      "FieldNames": ['Id', 'Name', 'State', 'Status', 'TimeTargeting', 'NegativeKeywords', 'ClientInfo', 'Type'],
      "TextCampaignFieldNames": ["BiddingStrategy"]
    })["Campaigns"].map{|c| new({ name: c["Name"], id: c["Id"], status: c["Status"], state: c["State"], type: c["Type"],
                                  target_hours: c["TimeTargeting"]["Schedule"]["Items"], owner_name: c["ClientInfo"],
                                  negative_keywords: c["NegativeKeywords"]["Items"], search_strategy: c["TextCampaign"]["BiddingStrategy"]["Search"]["BiddingStrategyType"], 
                                  network_strategy: c["TextCampaign"]["BiddingStrategy"]["Network"]["BiddingStrategyType"]})}
  end

  def self.add(params)
    if params.kind_of?(Array)
      batch_add(params)
    else
      special_parameters = params.text_campaign_parameters if  params.type.blank? || params.type == "TEXT_CAMPAIGN"
      params.id = YandexDirect.request(SERVICE, 'add', {"Campaigns": [params.parameters(special_parameters)]})["AddResults"].first["Id"]
      params
    end
  end

  def self.update(params)
    if params.kind_of?(Array)
      batch_update(params)
    else
      special_parameters = params.text_campaign_parameters if params.type.blank? || params.type == "TEXT_CAMPAIGN"
      params.id = YandexDirect.request(SERVICE, 'update', {"Campaigns": [params.parameters(special_parameters)]})["UpdateResults"].first["Id"]
      params
    end
  end

  def parameters(campaign_type)
    hash = {"Name": @name,
            "EndDate": @end_date,
            "ClientInfo": @owner_name,
            "Notification": {  
              "EmailSettings": {
                "Email": @email,
                "SendAccountNews": "YES",
                "SendWarnings": "YES"
              }
            },
            "TimeTargeting": {
              "Schedule": {
                "Items": @target_hours
              },
              "ConsiderWorkingWeekends": "YES",
              "HolidaysSchedule": {
                "SuspendOnHolidays": "NO",
                "BidPercent": 100,
                "StartHour": 0,
                "EndHour": 24
              } 
            },
            "TimeZone": @time_zone
          }
    hash["NegativeKeywords"] = @negative_keywords if @negative_keywords.present?
    hash["DailyBudget"] = {"Amount": @daily_budget_amount, "Mode": @daily_budget_mode} if @daily_budget_mode.present? && @daily_budget_amount.present?
    hash["BlockedIps"] = {"Items": @blocked_ips} if @blocked_ips.present?
    hash["ExcludedSites"] = {"Items": @excluded_sites} if @excluded_sites.present?
    hash["Id"] = @id if @id.present? && @id != 0
    hash["StartDate"] = @start_date if @start_date.present?
    hash[campaign_type.first] = campaign_type.last
    hash
  end

  def text_campaign_parameters
    ["TextCampaign", {"BiddingStrategy": {
                        "Search": {
                          "BiddingStrategyType": @search_strategy
                        }, 
                        "Network": { 
                          "BiddingStrategyType": @network_strategy,
                          "NetworkDefault": {
                            "LimitPercent": @limit_percent,
                            "BidPercent": @bid_percent
                          }
                        }
                      }
                    }
    ]
  end

  private

  def self.batch_add(campaigns)
    params = []
    campaigns.each do |campaign|
      special_parameters = campaign.text_campaign_parameters if campaign.type.blank? || campaign.type == "TEXT_CAMPAIGN"
      params.push(campaign.parameters(special_parameters))
    end
    params.each_slice(10) do |add_parameters|
      YandexDirect.request(SERVICE, 'add', {"Campaigns": add_parameters.compact})["AddResults"].map{|r| r["Id"]}
    end
  end

  def self.batch_update(campaigns)
    params = []
    campaigns.each do |campaign|
      special_parameters = campaign.text_campaign_parameters if campaign.type.blank? || campaign.type == "TEXT_CAMPAIGN"
      params.push(campaign.parameters(special_parameters))
    end
    params.each_slice(10) do |add_parameters|
      YandexDirect.request(SERVICE, 'update', {"Campaigns": add_parameters.compact})["UpdateResults"].map{|r| r["Id"]}
    end
  end
end
