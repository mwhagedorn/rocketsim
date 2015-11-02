require_relative 'spec_helper'
require_relative "../lib/pocket_rocket/engine_parser"


describe PocketRocket::RseParser do
  describe "when opening the files" do
    let(:parser){
      PocketRocket::EngineParser.new("../lib/pocket_rocket/engines/Estes_A8.rse")
    }
    it "pulls all the data out of the file" do
      parser.parse
      parser.manufacturer.must_equal "Estes"
      parser.code.must_equal "A8"
      parser.propellant_weight.must_be_close_to 0.0033
      parser.engine_weight.must_be_close_to 0.01635
      parser.thrust_curve.count.must_equal 24
      parser.thrust_curve.keys.sort.first.must_equal 0.0
      parser.thrust_curve.keys.sort.last.must_equal 0.73
      parser.thrust_curve[0.0].must_equal 0.0
      parser.burn_time.must_equal 0.73
      parser.mass_curve.count.must_equal 24
      parser.mass_curve[0.0].must_equal parser.engine_weight.to_f
      parser.mass_curve[parser.burn_time].must_equal (parser.engine_weight.to_f - parser.propellant_weight.to_f)
      parser.mass_curve[0.0].must_equal parser.engine_weight.to_f
      parser.to_h[:burn_time].must_equal parser.burn_time

    end
    it "creates a hash for thrustcurve data" do
      parser.parse
      parser.thrust_curve.must_be_instance_of Hash
    end
    it 'gets the burn_time' do

    end
  end
end