
require "json"
require 'capybara'
require "selenium-webdriver"
require 'benchmark'
require 'csv'
require 'capybara/dsl'

Capybara.run_server = false
Capybara.current_driver = :selenium
Capybara.app_host = 'http://localhost:2300/'
Capybara.default_max_wait_time = 10
Capybara.page.driver.browser.manage.window.maximize

REPEAT_TIMES = 1

class ReadPointTests
  include Capybara::DSL
  def initialize
    @times = Array.new(6, 0)
    @file_name = "../results/hanami_read_capybara_#{REPEAT_TIMES}.csv"
    @selectors = [
      "//div[@id='map']/div/div[4]/div[@title='Osiedle Barbara']",
      "//div[@id='map']/div/div[4]/div[@title='Nowa Wieś']",
      "//div[@id='map']/div/div[4]/div[@title='Osiedle Wanda']",
      "//div[@id='map']/div/div[4]/div[@title='Nowy Dwór']",
      "//div[@id='map']/div/div[4]/div[@title='Jerzmanowo']",
      "//div[@id='map']/div/div[4]/div[@title='Wojczyce']" 
    ]
  end

  def run_tests
    REPEAT_TIMES.times do
      prepare
      @selectors.each_with_index do |selector, index|
        @times[index] += Benchmark.realtime { read_points(selector) }
      end
    end
    puts @times
    # results = { " punktu" => @add_time/REPEAT_TIMES, "Zaktualizowanie punktu" => @update_time/REPEAT_TIMES, "Usunięcie punktu" => @delete_time/REPEAT_TIMES  }
    # CSV.open(@file_name, "wb") do |csv|
    #   csv << results.keys
    #   csv << results.values
    # end
  end

  private
  
  def prepare
    visit('/')
    page.has_xpath?('//*[@id="map"]/div[1]/div[9]/svg/g/path[1]')
    click_button("clear-points")
    click_button("clear-lines") 
    click_button("clear-polygons")
    click_button("all-points")
    click_button("Refresh")
    sleep 5
    find(:css, '.leaflet-control-zoom-in').click
    sleep 5
  end
  
  def read_points(selector)
    find(:css, '.leaflet-control-zoom-out').click
    page.has_xpath?(selector)
  end
end

ReadTests.new.run_tests