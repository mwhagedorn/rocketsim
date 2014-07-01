require_relative 'spec_helper'
require_relative "../wrasp_parser"
require_relative "../engine"


describe WraspParser do
  describe "when loading thrustcurve files" do
      let(:parsed_data){
        WraspParser.new("../engines/Estes_A8.eng").parse.to_h
      }
      let(:engine){
        Engine.new(parsed_data)
      }
      it "sets the burn time" do
        engine.burn_time.must_equal 0.703
      end
      it "sets the propellant mass" do
        engine.propellant_weight.must_equal 0.0033
      end
      it "sets the engine total mass" do
        engine.engine_weight.must_equal 0.01635
      end
      it "sets the mass per time(50)" do
        engine.mass_at_time(engine.burn_time/2.0).must_equal 0.0147
      end

      it "sets the mass per time(100)" do
        engine.mass_at_time(engine.burn_time).must_equal(0.013049999999999999)
      end
  end
end