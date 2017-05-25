
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

class ReadLineTests
  include Capybara::DSL
  def initialize
    @times = Array.new(5, 0)
    @file_name = "../results/hanami_read_lines_capybara_#{REPEAT_TIMES}.csv"
     @line_css_prefix = "div#map.leaflet-container.leaflet-retina.leaflet-fade-anim.leaflet-grab.leaflet-touch-drag " +
      "div.leaflet-pane.leaflet-map-pane div.leaflet-pane.leaflet-lines-pane svg.leaflet-zoom-animated g path"
    @selectors = [
      ".Gwarna",
      ".Zaolziańska",
      ".Krucza",
      ".Podróżnicza"
    ]
  end

  def run_tests
    REPEAT_TIMES.times do
      prepare
      click_button("all-lines")
      @times[0] += Benchmark.realtime { click_button("Refresh"); page.has_css?(@line_css_prefix + ".Komandorska")}
      @selectors.each_with_index do |selector, index|
        @times[index+1] += Benchmark.realtime { read_points(@line_css_prefix + selector) }
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
    click_button("Refresh")
    find(:css, '.leaflet-control-zoom-in').click
    find(:css, '.leaflet-control-zoom-in').click
    find(:css, '.leaflet-control-zoom-in').click
    find(:css, '.leaflet-control-zoom-in').click
    sleep 5
  end
  
  def read_points(selector)
    find(:css, '.leaflet-control-zoom-out').click
    page.has_css?(selector)
  end
end

ReadLineTests.new.run_tests