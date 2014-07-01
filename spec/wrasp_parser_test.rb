require_relative 'spec_helper'
require_relative "../wrasp_parser"


describe WraspParser do
  describe "when opening the files" do
      let(:parser){
        WraspParser.new("../engines/Estes_A8.eng")
      }
      it "pulls all the data out of the file" do
        parser.parse
        parser.manufacturer.must_equal "Estes"
        parser.code.must_equal "A8"
        parser.propellant_weight.must_equal "0.0033"
        parser.engine_weight.must_equal "0.01635"
        parser.thrust_curve.count.must_equal 22
      end
      it "creates a hash for thrustcurve data" do
        parser.parse
        parser.thrust_curve.must_be_instance_of Hash
      end
  end
end