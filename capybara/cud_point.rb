
require "json"
require 'capybara'
require "selenium-webdriver"
require 'benchmark'
require 'csv'
require 'capybara/dsl'

Capybara.run_server = false
Capybara.current_driver = :selenium
Capybara.app_host = 'http://localhost:2300/'
Capybara.default_max_wait_time = 5

REPEAT_TIMES = 1

class CudPointTests
  include Capybara::DSL
  def initialize
    @add_time = 0
    @update_time = 0
    @delete_time = 0
    @file_name = "../results/hanami_cud_capybara_#{REPEAT_TIMES}.csv" 
  end

  def run_tests
    prepare
    REPEAT_TIMES.times do
      @add_time += Benchmark.realtime { add_point }
      @update_time += Benchmark.realtime { update_point }
      @delete_time += Benchmark.realtime { delete_point }
    end
    results = { "Dodanie punktu" => @add_time/REPEAT_TIMES, "Zaktualizowanie punktu" => @update_time/REPEAT_TIMES, "Usunięcie punktu" => @delete_time/REPEAT_TIMES  }
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
    page.execute_script('$("#point_types").val(["część kolonii"]).trigger("change")')
    click_button("refresh-map")
  end
  
  def add_point
    click_button('Add')
    find('#point').click
    fill_in('point-name', with: 'test')
    fill_in('point-coordinates', with: 'POINT (17.027702175405757 51.09629326329068)')
    fill_in('point-terc', with: '1234567')
    click_button('Create')
    page.has_xpath?("//div[@id='map']/div/div[4]/div/span")
  end

  def update_point
    find(:xpath, "//div[@id='map']/div/div[4]/div/span").click
    fill_in('point-name', with: 'updated')
    fill_in('point-coordinates', with: 'POINT (17.028702175405757 51.09629326329068)')
    fill_in('point-terc', with: '4567123')
    click_button('Update')
    page.has_xpath?("//div[@id='map']/div/div[4]/div[@title='updated']")
  end

  def delete_point
    find(:xpath, "//div[@id='map']/div/div[4]/div/span").click
    click_link('Delete')
    page.has_no_xpath?("//div[@id='map']/div/div[4]/div[@title='updated']")
  end
end

CudTests.new.run_tests