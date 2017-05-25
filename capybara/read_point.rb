require "json"
require 'capybara'
require "selenium-webdriver"
require 'benchmark'
require 'csv'
require 'capybara/dsl'

class ReadPointTests
  include Capybara::DSL
  def initialize(address, framework, repeat_times)
    @repeat_times = repeat_times
    @times = Array.new(6, 0)
    @counts = Array.new(6, nil)
    @file_name = "../results/#{framework}_read_points_capybara_#{@repeat_times}.csv"
    @selectors = [
      "//div[@id='map']/div/div[4]/div[@title='Osiedle Barbara']",
      "//div[@id='map']/div/div[4]/div[@title='Nowa Wieś']",
      "//div[@id='map']/div/div[4]/div[@title='Osiedle Wanda']",
      "//div[@id='map']/div/div[4]/div[@title='Nowy Dwór']",
      "//div[@id='map']/div/div[4]/div[@title='Jerzmanowo']",
      "//div[@id='map']/div/div[4]/div[@title='Wojczyce']" 
    ]

    Capybara.run_server = false
    Capybara.current_driver = :selenium
    Capybara.app_host = address
    Capybara.default_max_wait_time = 15
    Capybara.page.driver.browser.manage.window.maximize
  end

  def run_tests
    @repeat_times.times do
      prepare
      @selectors.each_with_index do |selector, index|
        @times[index] += Benchmark.realtime { read_points(selector) }
        @counts[index] ||= find('#points_count').text
      end
    end
    CSV.open(@file_name, "wb") do |csv|
      csv << ['Ilość punktów', 'Czas [s]']
      @times.each_with_index do |time, index|
        csv << [@counts[index], time/@repeat_times]
      end
    end
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