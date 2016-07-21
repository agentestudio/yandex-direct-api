class YandexDirect::Sitelink
  SERVICE = 'sitelinks'

  def self.add_set(params)
    sitelinks = params.map do |link|
      hash = {"Title": link[:title], "Href": link[:href]}
      hash["Description"] = link[:description] if link[:description].present?
      hash
    end
    YandexDirect.request(SERVICE, 'add', {"SitelinksSets": [{"Sitelinks": sitelinks}]})["AddResults"].first["Id"]
  end

  def self.get(ids)
    YandexDirect.request(SERVICE, 'get', {"SelectionCriteria": {"Ids": ids}, "FieldNames": ["Id", "Sitelinks"]})["SitelinksSets"]
  end

  def self.delete(ids)
    YandexDirect.request(SERVICE, 'delete', {"SelectionCriteria": {"Ids": ids}})
  end
end
