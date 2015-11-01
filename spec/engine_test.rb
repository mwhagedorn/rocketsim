require_relative 'spec_helper'
require_relative "../lib/pocket_rocket/engine_parser"
require_relative "../lib/pocket_rocket/engine"


describe PocketRocket::Engine do
  describe "Wrasp Files" do
    describe "when loading wrasp files" do
      let(:parsed_data){
        PocketRocket::EngineParser.new("../lib/pocket_rocket/engines/Estes_A8.eng").parse.to_h
      }
      let(:engine){
        PocketRocket::Engine.new(parsed_data)
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
  describe "RSE files" do
    describe "when loading rse files" do
      let(:parsed_data){
        PocketRocket::EngineParser.new("../lib/pocket_rocket/engines/Estes_A8.rse").parse.to_h
      }
      let(:engine){
        PocketRocket::Engine.new(parsed_data)
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

end