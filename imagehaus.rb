require 'httpi'
require 'api-auth'
require 'nokogiri'

class Imagehaus
  def self.image_url(work_image_id)
    request = HTTPI::Request.new("http://ih.redbubble-staging.com/work_images/#{work_image_id}/original_image_url")
    request.body = ""
    request.headers = { 'Content-Type' => 'application/xml', 'Date' => Time.now.utc.httpdate }

    signed_request = ApiAuth.sign!(request, 'image_detail_client', File.read('secret.txt').chomp)

    response = HTTPI.get(signed_request)
    Nokogiri::XML(response.body).css("original-image-url").first.content
  end
end
