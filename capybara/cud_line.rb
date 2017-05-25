
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

REPEAT_TIMES = 1

class CudLineTests
  include Capybara::DSL
  def initialize
    @add_time = 0
    @update_time = 0
    @delete_time = 0
    @file_name = "../results/hanami_cud_line_capybara_#{REPEAT_TIMES}.csv"
    @line_css_prefix = "div#map.leaflet-container.leaflet-retina.leaflet-fade-anim.leaflet-grab.leaflet-touch-drag " +
      "div.leaflet-pane.leaflet-map-pane div.leaflet-pane.leaflet-lines-pane svg.leaflet-zoom-animated g path"
  end

  def run_tests
    prepare
    REPEAT_TIMES.times do
      @add_time += Benchmark.realtime { add_point }
      @update_time += Benchmark.realtime { update_point }
      @delete_time += Benchmark.realtime { delete_point }
    end
    results = { "Dodanie lini" => @add_time/REPEAT_TIMES, "Zaktualizowanie lini" => @update_time/REPEAT_TIMES, "Usunięcie lini" => @delete_time/REPEAT_TIMES  }
    CSV.open(@file_name, "wb") do |csv|
      csv << results.keys
      csv << results.values
    end
  end

  private
  
  def prepare
    visit('/')
    page.has_xpath?('//*[@id="map"]/div[1]/div[9]/svg/g/path[1]')
    click_button("clear-points")
    click_button("clear-lines") 
    click_button("clear-polygons")
    page.execute_script('$("#line_types").val(["custom"]).trigger("change")')
    click_button("refresh-map")
    page.has_no_css?(@line_css_prefix)
  end
  
  def add_point
    click_button('Add')
    find('#line').click
    fill_in('line-name', with: 'testline')
    fill_in('line-coordinates', with: 'MULTILINESTRING ((17.0245292 51.1038569, 17.0246197 51.1038414, '+
      '17.0246424 51.1038374, 17.0247252 51.1038231, 17.0247591 51.103816, 17.0248074 51.1038072, 17.0248521 51.103801, '+
      '17.024952800000005 51.103791400000006, 17.0250006 51.1037864, 17.0256233 51.1036778, 17.0256279 51.1036769, '+
      '17.0257964 51.10364030000001, 17.0258341 51.1036341, 17.0258375 51.1036335, 17.0258755 51.1036253, '+
      '17.0259168 51.1036175, 17.0259586 51.1036111, 17.0259857 51.1036068, 17.0260478 51.1035967, 17.0261264 51.1035833, '+
      '17.0261837 51.1035735, 17.026223 51.1035668, 17.0262658 51.10356, 17.0263055 51.103553700000006, 17.026395 51.1035396, '+
      '17.0269314 51.1034409, 17.0275772 51.1033206, 17.0276276 51.1033112, 17.0277472 51.103289, 17.027949 51.103251300000004, '+
      '17.0280547 51.1032317, 17.0281104 51.1032213, 17.0281351 51.1032169, 17.0286699 51.1031153, 17.0287102 51.1031076, '+
      '17.0287345 51.103103, 17.0290319 51.1030461, 17.0290744 51.103038, 17.0291172 51.10303, 17.0291394 51.1030259, 17.0291855 51.1030174))')
    select('custom', from: 'Road type')
    click_button('Create')
    page.has_css?(@line_css_prefix + ".testline")
  end

  def update_point
    find(:css, @line_css_prefix + ".testline").click
    fill_in('line-name', with: 'updatedline')
    fill_in('line-coordinates', with: 'MULTILINESTRING ((17.0244292 51.1038569, 17.0246197 51.1038414, '+
      '17.0246424 51.1038374, 17.0247252 51.1038231, 17.0247591 51.103816, 17.0248074 51.1038072, 17.0248521 51.103801, '+
      '17.024952800000005 51.103791400000006, 17.0250006 51.1037864, 17.0256233 51.1036778, 17.0256279 51.1036769, '+
      '17.0257964 51.10364030000001, 17.0258341 51.1036341, 17.0258375 51.1036335, 17.0258755 51.1036253, '+
      '17.0259168 51.1036175, 17.0259586 51.1036111, 17.0259857 51.1036068, 17.0260478 51.1035967, 17.0261264 51.1035833, '+
      '17.0261837 51.1035735, 17.026223 51.1035668, 17.0262658 51.10356, 17.0263055 51.103553700000006, 17.026395 51.1035396, '+
      '17.0269314 51.1034409, 17.0275772 51.1033206, 17.0276276 51.1033112, 17.0277472 51.103289, 17.027949 51.103251300000004, '+
      '17.0280547 51.1032317, 17.0281104 51.1032213, 17.0281351 51.1032169, 17.0286699 51.1031153, 17.0287102 51.1031076, '+
      '17.0287345 51.103103, 17.0290319 51.1030461, 17.0290744 51.103038, 17.0291172 51.10303, 17.0291394 51.1030259, 17.0291855 51.1030174))')
    click_button('Update')
    page.has_css?(@line_css_prefix + ".updatedline")
  end

  def delete_point
    find(:css, @line_css_prefix + ".updatedline").click
    click_link('Delete')
    page.has_no_css?(@line_css_prefix + ".updatedline")
  end
end

CudLineTests.new.run_tests