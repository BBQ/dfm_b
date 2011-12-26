# encoding: utf-8
task :parse_min do
  
  require 'rubygems'
  require 'net/http'
  require 'uri'
  require 'builder'
  require 'nokogiri'
  
  
  endpoint = 'http://188.93.18.50/MenutkaSoap/MenutkaSoapService.svc'
  soap = 'http://schemas.xmlsoap.org/soap/envelope/'
  service =  'http://www.w3.org/2002/ws/databinding/examples/6/05/'
  operation = "http://menutka.com/IMenutka/FilterRestaurants"

  # xml = Builder::XmlMarkup.new
  # xml.Envelope :xmlns => soap do
  #   xml.Body do
  #      xml.tag! operation, 'Be like the squirrel!', :xmlns => service
  #   end
  # end

  module Net
    module HTTPHeader
      def x( k )
        return "SOAPAction" if k == 'soapaction'
        k.split(/-/).map {|i| i.capitalize }.join('-')
      end
    end
  end
  
  uri = URI.parse(endpoint)
  http = Net::HTTP.new(uri.host)
  #http.set_debug_output $stderr

  req_headers= {
    'Content-Type' => 'text/xml; charset=utf-8',
    'User-Agent' => 'wsdl2objc',
    'Accept' => '*/*',
    'SOAPAction' => operation,
    'Connection' => 'keep-alive'
  }

  req_body = '<?xml version="1.0"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:MenutkaService="http://tempuri.org/" xmlns:tns1="http://menutka.com" xmlns:ns1="http://menutka.com/Imports" xmlns:tns2="http://schemas.datacontract.org/2004/07/MenutkaPrivateService" xmlns:tns3="http://schemas.microsoft.com/2003/10/Serialization/Arrays" xmlns:tns4="http://schemas.microsoft.com/2003/10/Serialization/" xsl:version="1.0">
    <soap:Body>
      <tns1:FilterRestaurants>
        <tns1:filters>
          <tns2:Filter>
            <tns2:Id>4</tns2:Id>
            <tns2:NumericValues>
              <tns3:double>55.7056388662844</tns3:double>
              <tns3:double>37.62119371431132</tns3:double>
            </tns2:NumericValues>
            <tns2:Switcher>true</tns2:Switcher>
            <tns2:Type>3</tns2:Type>
          </tns2:Filter>
        </tns1:filters>
        <tns1:from>0</tns1:from>
        <tns1:to>15</tns1:to>
      </tns1:FilterRestaurants>
    </soap:Body>
  </soap:Envelope>'
  
  response = http.request_post(uri.path, req_body, req_headers)
  doc = Nokogiri::XML::Reader(response.body.force_encoding("UTF-8"))
  # data = Zlib::Inflate.inflate(response.body.to_s)
  %x{echo "#{response.body}"  > log.xml}
  # p response.body
  # doc.each do |node|
  # 
  #     # node is an instance of Nokogiri::XML::Reader
  #     p "#{node.name}: #{node.value}"
  # 
  #   end
  
  # p doc.document.root
  
end