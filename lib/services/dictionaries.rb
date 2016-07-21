module YandexDirect::Dictionaries
  SERVICE = 'dictionaries'

  def self.get_regions
    YandexDirect.request(SERVICE, 'get', {"DictionaryNames": ["GeoRegions"]})["GeoRegions"]
  end
end
