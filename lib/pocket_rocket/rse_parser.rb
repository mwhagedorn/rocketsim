require 'nokogiri'

module PocketRocket
  class RseParser

    attr_accessor :context

    def initialize(context)
      @context = context
    end

    def parse
      doc = File.open(context.filename) { |f| Nokogiri::XML(f) }
      context.code = doc.xpath('string(//engine/@code)')
      context.diameter = doc.xpath('string(//engine/@dia)')
      context.length = doc.xpath('string(//engine/@len)')
      context.delay =doc.xpath('string(//engine/@delays)')
      context.propellant_weight = doc.xpath('number(//engine/@propWt)').to_f*0.001
      context.engine_weight =doc.xpath('number(//engine/@initWt)').to_f*0.001
      context.manufacturer  =doc.xpath('string(//engine/@mfg)')
      context.burn_time = doc.xpath('number(//engine/@burn-time)')
      doc.xpath('//eng-data').each do |node|
        time_stamp = node.attribute('t').value.to_f
        force = node.attribute('f').value.to_f
        mass = ((context.engine_weight.to_f - context.propellant_weight) + node.attribute('m').value.to_f*0.001)
        context.add_data_point([time_stamp, [force, mass]])
      end
    end
  end
end