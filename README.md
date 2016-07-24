# yandex-direct-api
Интеграция с API Yandex Direct v.5

Гем написан для проекта (срочная необходимость перехода на API 5 версии), присутствует обёртка запросов к сервисам Campaigns, AdGroups, Ads, VCards, Dictionaries, Bids, Sitelinks, Keywords в модуле YandexDirect. Также есть модуль YandexDirect::Live, который предоставляет некоторые функции работы с изображениями, ещё не представленные в 5 верии API.

В планах: расширение функционала, документация.

gem 'yandex-direct-api'

bundle

rake yandex_direct:install

Внесите изменения в config/yandex_direct_api.yml
