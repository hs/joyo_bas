require 'thor'
require 'date'

module JoyoBas
  class Cli < Thor
    desc "joyo_bas get", "get Bank account status"
    def get
      conf = Config.new
      crawler = Crawler.new(conf)
      result = crawler.fetch

      xlsx = Exporter.new(conf.path, result)
      xlsx.append_data
      xlsx.save
    end
  end
end
