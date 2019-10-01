#!/usr/bin/python

import urllib.request
import os, sys
import json


#tf_object = "media_server"
#uri = "/"
#pattern = "Index"
subdomain = sys.argv[1]
uri = sys.argv[2]
pattern = sys.argv[3]

server_name = ""

# Load inventory from terraform
inventory = json.loads(os.popen("terraform show -json").read())

for resource in inventory['values']['root_module']['resources']:
    if resource['name'] == "a_sub":
        server_name = resource['values']['subdomain'] + "." + resource['values']['zone']

if subdomain == "root":
    subdomain = ""
else:
    subdomain = subdomain + "."
# Fetch the URL
url = "http://" + subdomain + server_name + uri
print(url)

try:
    request = urllib.request.urlopen(url, timeout = 10)
except urllib.error.HTTPError as e:
    print(e.reason)
    exit(1)
except urllib.error.URLError as e:
    print(e.reason)
    exit(1)
else:
    content = request.read().decode('utf-8')
    if(content.find(pattern) != -1):
        print("OK")
    else:
        print("Pattern \"" + pattern + "\" not found in " + url)
        exit(1)
