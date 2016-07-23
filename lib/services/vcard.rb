class YandexDirect::VCard
  SERVICE = 'vcards'

  def self.get(ids = nil)
    params = {"FieldNames": ["Id", "Country", "City", "Street", "House", "Building", "Apartment", "CompanyName", "ExtraMessage", "ContactPerson", "ContactEmail", "MetroStationId", "CampaignId", "Ogrn", "WorkTime", "InstantMessenger", "Phone", "PointOnMap"]}
    params["SelectionCriteria"] = {"Ids": ids} if ids.present?
    YandexDirect.request(SERVICE, 'get', params)["VCards"]
  end

  def self.add(params)
    vcard = { "CampaignId": params[:campaign_id],
              "Country": params[:country],
              "City": params[:city],
              "CompanyName": params[:company_name],
              "WorkTime": params[:work_time],
              "Phone": {
                "CountryCode": params[:country_code],
                "CityCode": params[:city_code],
                "PhoneNumber": params[:phone_number],
                "Extension": params[:phone_extension],
              }
            }
    %w(Street House Building Apartment ExtraMessage Ogrn ContactEmail MetroStationId ContactPerson).each do |key| 
      vcard[key] = params[key.underscore.to_sym] if params[key.underscore.to_sym].present?
    end
    if params[:messenger_client].present? && params[:messenger_login].present?
      vcard["InstantMessenger"]["MessengerClient"] = params[:messenger_client]
      vcard["InstantMessenger"]["MessengerLogin"] = params[:messenger_login]
    end
    YandexDirect.request(SERVICE, 'add', {"VCards": [vcard]})["AddResults"].first["Id"]
  end

  def self.delete(ids)
    YandexDirect.request(SERVICE, 'delete', {"SelectionCriteria": {"Ids": ids}})
  end
end
