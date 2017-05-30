require "json"
require 'capybara'
require "selenium-webdriver"
require 'benchmark'
require 'csv'
require 'capybara/dsl'

class CudPointTests
  include Capybara::DSL
  def initialize(address, framework, repeat_times)
    @repeat_times = repeat_times
    @add_time = 0
    @read_time = 0
    @update_time = 0
    @delete_time = 0
    @file_name = "../results/#{framework}_cud_point_capybara_#{@repeat_times}.csv"

    Capybara.run_server = false
    Capybara.current_driver = :selenium
    Capybara.app_host = address
    Capybara.default_max_wait_time = 15
  end

  def run_tests
    prepare
    @repeat_times.times do
      @add_time += Benchmark.realtime { add_point }
      prepare_read
      @read_time += Benchmark.realtime { read_point }
      @update_time += Benchmark.realtime { update_point }
      @delete_time += Benchmark.realtime { delete_point }
    end
    results = { "Wyświetlenie punktu" => @read_time/@repeat_times,
      "Dodanie punktu" => @add_time/@repeat_times,
      "Zaktualizowanie punktu" => @update_time/@repeat_times,
      "Usunięcie punktu" => @delete_time/@repeat_times  }
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
    page.execute_script('$("#point_types").val(["część kolonii"]).trigger("change")')
    click_button("refresh-map")
  end

  def prepare_read
    click_button("clear-points")
    click_button("refresh-map")
    page.execute_script('$("#point_types").val(["część kolonii"]).trigger("change")')
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

  def read_point
    click_button("refresh-map")
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