
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

class CudPolygonTests
  include Capybara::DSL
  def initialize
    @add_time = 0
    @update_time = 0
    @delete_time = 0
    @file_name = "../results/hanami_cud_polygon_capybara_#{REPEAT_TIMES}.csv"
    @polygon_xpath_prefix = 'html body div#maps.col-md-8 div#mappage div#map.leaflet-container.leaflet-retina.leaflet-fade-anim.leaflet-grab.leaflet-touch-drag div.leaflet-pane.leaflet-map-pane div.leaflet-pane.leaflet-polygons-pane svg.leaflet-zoom-animated g path'
  end

  def run_tests
    prepare
    REPEAT_TIMES.times do
      @add_time += Benchmark.realtime { add }
      @update_time += Benchmark.realtime { update }
      @delete_time += Benchmark.realtime { delete }
    end
    results = { "Dodanie wielokątu" => @add_time/REPEAT_TIMES, "Zaktualizowanie wielokątu" => @update_time/REPEAT_TIMES, "Usunięcie wielokątu" => @delete_time/REPEAT_TIMES  }
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
    page.execute_script('$("#polygon_type").val(5).trigger("change")')
    click_button("refresh-map")
    page.has_no_css?(@polygon_xpath_prefix)
  end
  
  def add
    click_button('Add')
    find('#polygon').click
    fill_in('polygon-name', with: 'testpolygon')
    fill_in('polygon-coordinates', with: 'MULTIPOLYGON(((17.025461196899414 51.10336531155195,17.020225524902344 51.10298804796575,'+
      '17.019367218017578 51.10085914573741,17.01910972595215 51.0994308399253,17.01829433441162 51.09821809280455,17.020010948181152 51.09662799838328,'+
      '17.020397186279297 51.09474137475155,17.023401260375977 51.094283183109354,17.024216651916504 51.092935534318435,17.02601909637451 51.09455270815461,'+
      '17.02885150909424 51.09282772071848,17.03481674194336 51.09209997234422,17.029967308044434 51.094283183109354,17.0343017578125 51.09541517774241,'+
      '17.03378677368164 51.093824986927075,17.036919593811035 51.09331287993879,17.041125297546387 51.094417945828376,17.040867805480957 51.09910744380352,'+
      '17.03730583190918 51.097786886162154,17.035245895385742 51.10091304320592,17.038249969482422 51.102287407422885,17.033400535583496 51.102961100448944,'+
      '17.029237747192383 51.10309583787599,17.025976181030273 51.102233511556676,17.025461196899414 51.10336531155195)))')
    select('custom', from: 'Unit type')
    fill_in('polygon-terc', with: '1234567')
    click_button('Create')
    page.has_css?(@polygon_xpath_prefix + '.testpolygon')
  end

  def update
    find(:css, @polygon_xpath_prefix + '.testpolygon').click
    fill_in('polygon-name', with: 'updatedpolygon')
    fill_in('polygon-coordinates', with: 'MULTIPOLYGON(((17.025461196899414 51.10336531155195,17.020225524902344 51.10298804796575,17.019367218017578 51.10085914573741,'+
      '17.01910972595215 51.0994308399253,17.01829433441162 51.09821809280455,17.020010948181152 51.09662799838328,17.020397186279297 51.09474137475155,'+
      '17.023401260375977 51.094283183109354,17.024216651916504 51.092935534318435,17.02601909637451 51.09455270815461,17.02885150909424 51.09282772071848,'+
      '17.03481674194336 51.09209997234422,17.029967308044434 51.094283183109354,17.0343017578125 51.09541517774241,17.03378677368164 51.093824986927075,'+
      '17.036919593811035 51.09331287993879,17.041125297546387 51.094417945828376,17.040867805480957 51.09910744380352,17.03730583190918 51.097786886162154,'+
      '17.037391662597656 51.10077829941675,17.038249969482422 51.102287407422885,17.033400535583496 51.102961100448944,17.029237747192383 51.10309583787599,'+
      '17.025976181030273 51.102233511556676,17.025461196899414 51.10336531155195)))')
    click_button('Update')
    page.has_css?(@polygon_xpath_prefix + '.updatedpolygon')
  end

  def delete
    find(:css, @polygon_xpath_prefix + '.updatedpolygon').click
    click_link('Delete')
    page.has_no_css?(@polygon_xpath_prefix + '.updatedpolygon')
  end
end

CudPolygonTests.new.run_tests