
require "json"
require 'capybara'
require "selenium-webdriver"
require 'benchmark'
require 'csv'
require 'capybara/dsl'

class CudLineTests
  include Capybara::DSL
  def initialize(address, framework, repeat_times)
    @repeat_times = repeat_times
    @add_time = 0
    @read_time = 0
    @update_time = 0
    @delete_time = 0
    @file_name = "../results/#{framework}_cud_line_capybara_#{@repeat_times}.csv"
    @line_css_prefix = "div#map.leaflet-container.leaflet-retina.leaflet-fade-anim.leaflet-grab.leaflet-touch-drag " +
      "div.leaflet-pane.leaflet-map-pane div.leaflet-pane.leaflet-lines-pane svg.leaflet-zoom-animated g path"

    Capybara.run_server = false
    Capybara.current_driver = :selenium
    Capybara.app_host = address
    Capybara.default_max_wait_time = 15
  end

  def run_tests
    prepare
    @repeat_times.times do
      @add_time += Benchmark.realtime { add_line }
      prepare_read
      @read_time += Benchmark.realtime { read_line }
      @update_time += Benchmark.realtime { update_line }
      @delete_time += Benchmark.realtime { delete_line }
    end
    results = { "Wyświetlenie linii" => @read_time/@repeat_times,
      "Dodanie linii" => @add_time/@repeat_times,
      "Zaktualizowanie linii" => @update_time/@repeat_times,
      "Usunięcie linii" => @delete_time/@repeat_times  }
    CSV.open(@file_name, "wb") do |csv|
      results.each do |key, value|
        csv << [key, value]
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
    page.execute_script('$("#line_types").val(["custom"]).trigger("change")')
    click_button("refresh-map")
    page.has_no_css?(@line_css_prefix)
  end

  def prepare_read
    click_button("clear-lines")
    click_button("refresh-map")
    page.execute_script('$("#line_types").val(["custom"]).trigger("change")')
  end
  
  def add_line
    click_button('Add')
    find('#line').click
    fill_in('line-name', with: 'testline')
    fill_in('line-coordinates', with: 'MULTILINESTRING ((17.0245292 51.1038569, 17.0291855 51.1030174))')
    select('custom', from: 'Road type')
    click_button('Create')
    page.has_css?(@line_css_prefix + ".testline")
  end

  def read_line
    click_button("refresh-map")
    page.has_css?(@line_css_prefix + ".testline")
  end

  def update_line
    find(:css, @line_css_prefix + ".testline").click
    fill_in('line-name', with: 'updatedline')
    fill_in('line-coordinates', with: 'MULTILINESTRING ((17.0244292 51.1038569, 17.0291855 51.1030174))')
    click_button('Update')
    page.has_css?(@line_css_prefix + ".updatedline")
  end

  def delete_line
    find(:css, @line_css_prefix + ".updatedline").click
    click_link('Delete')
    page.has_no_css?(@line_css_prefix + ".updatedline")
  end
end
