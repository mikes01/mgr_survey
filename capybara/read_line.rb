
require "json"
require 'capybara'
require "selenium-webdriver"
require 'benchmark'
require 'csv'
require 'capybara/dsl'

class ReadLineTests
  include Capybara::DSL
  def initialize(address, framework, repeat_times)
    @repeat_times = repeat_times
    @times = Array.new(5, 0)
    @counts = Array.new(5, nil)
    @file_name = "../results/#{framework}_read_lines_capybara_#{@repeat_times}.csv"
     @line_css_prefix = "div#map.leaflet-container.leaflet-retina.leaflet-fade-anim.leaflet-grab.leaflet-touch-drag " +
      "div.leaflet-pane.leaflet-map-pane div.leaflet-pane.leaflet-lines-pane svg.leaflet-zoom-animated g path"
    @selectors = [
      ".Czysta",
      ".Studzienna",
      ".Lwowska",
      ".Kampinoska"
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
      page.execute_script('$("#line_types").val(["residential", "secondary", "secondary_link", "primary", "primary_link",'+
        '"tertiary", "tertiary_link", "living_street"]).trigger("change")')
      @times[0] += Benchmark.realtime { click_button("Refresh"); page.has_css?(@line_css_prefix + ".Komandorska")}
      @counts[0] ||= find('#lines_count').text 
      @selectors.each_with_index do |selector, index|
        @times[index+1] += Benchmark.realtime { read_lines(@line_css_prefix + selector) }
        @counts[index+1] ||= find('#lines_count').text
      end
    end
    CSV.open(@file_name, "wb") do |csv|
      csv << ['count', 'time']
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
    click_button("Refresh")
    find(:css, '.leaflet-control-zoom-in').click
    find(:css, '.leaflet-control-zoom-in').click
    find(:css, '.leaflet-control-zoom-in').click
    find(:css, '.leaflet-control-zoom-in').click
    sleep 5
  end
  
  def read_lines(selector)
    find(:css, '.leaflet-control-zoom-out').click
    page.has_css?(selector)
  end
end