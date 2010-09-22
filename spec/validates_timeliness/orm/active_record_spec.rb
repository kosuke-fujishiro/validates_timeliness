require 'spec_helper'

describe ValidatesTimeliness, 'ActiveRecord' do
  it 'should define class validation methods' do
    ActiveRecord::Base.should respond_to(:validates_date)
    ActiveRecord::Base.should respond_to(:validates_time)
    ActiveRecord::Base.should respond_to(:validates_datetime)
  end

  it 'should define instance validation methods' do
    ActiveRecord::Base.instance_methods.should include('validates_date')
    ActiveRecord::Base.instance_methods.should include('validates_time')
    ActiveRecord::Base.instance_methods.should include('validates_datetime')
  end

  it 'should define _timeliness_raw_value_for instance method' do
    Employee.instance_methods.should include('_timeliness_raw_value_for')
  end
  
  context "attribute write method" do
    class EmployeeWithCache < ActiveRecord::Base
      set_table_name 'employees'
      validates_datetime :birth_datetime
    end

    it 'should cache attribute raw value' do
      r = EmployeeWithCache.new
      r.birth_datetime = date_string = '2010-01-01'
      r._timeliness_raw_value_for(:birth_datetime).should == date_string
    end

    context "with plugin parser" do
      class EmployeeWithParser < ActiveRecord::Base
        set_table_name 'employees'
        validates_date :birth_date
        validates_datetime :birth_datetime
      end

      before :all do
        ValidatesTimeliness.use_plugin_parser = true
      end

      it 'should parse a string value' do
        ValidatesTimeliness::Parser.should_receive(:parse) 
        r = EmployeeWithParser.new
        r.birth_date = '2010-01-01'
      end

      it 'should parse string as current timezone' do
        r = EmployeeWithParser.new
        r.birth_datetime = '2010-01-01 12:00'
        r.birth_datetime.zone == Time.zone.name
      end

      after :all do
        ValidatesTimeliness.use_plugin_parser = false
      end
    end
  end

  context "before_type_cast method" do
    it 'should be defined on class if ORM supports it' do
      Employee.instance_methods(false).should include("birth_datetime_before_type_cast")
    end

    it 'should return original value' do
      r = Employee.new
      r.birth_datetime = date_string = '2010-01-01'
      r.birth_datetime_before_type_cast.should == date_string
    end
  end
end