
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

class ReadPolygonTests
  include Capybara::DSL
  def initialize
    @times = Array.new(5, 0)
    @counts = Array.new(5, nil)
    @file_name = "../results/hanami_read_polygons_capybara_#{REPEAT_TIMES}.csv"
    @polygon_css_prefix = 'div.leaflet-pane.leaflet-map-pane div.leaflet-pane.leaflet-polygons-pane svg.leaflet-zoom-animated g path'
    @selectors = [
      ".Grabiszyn",
      ".Popowice",
      ".Pilczyce",
      ".Ratyń"
    ]
  end

  def run_tests
    REPEAT_TIMES.times do
      prepare
      page.execute_script('$("#polygon_type").val(3).trigger("change")')
      @times[0] += Benchmark.realtime { click_button("Refresh"); page.has_css?(@polygon_css_prefix + ".Południe")}
      @counts[0] ||= find('#polygons_count').text 
      @selectors.each_with_index do |selector, index|
        @times[index+1] += Benchmark.realtime { read_polygons(@polygon_css_prefix + selector) }
        @counts[index+1] ||= find('#polygons_count').text
      end
    end
    CSV.open(@file_name, "wb") do |csv|
      csv << ['Ilość wielokątów', 'Czas [s]']
      @times.each_with_index do |time, index|
        csv << [@counts[index], time/REPEAT_TIMES]
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
    click_button("Refresh")
    page.has_no_xpath?('//*[@id="map"]/div[1]/div[9]/svg/g/path[1]')
    sleep 5
  end
  
  def read_polygons(selector)
    find(:css, '.leaflet-control-zoom-out').click
    page.has_css?(selector)
  end
end

ReadPolygonTests.new.run_tests