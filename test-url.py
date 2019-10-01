#!/usr/bin/python

import urllib.request
import os, sys
import json


#tf_object = "media_server"
#uri = "/"
#pattern = "Index"
tf_object = sys.argv[1]
uri = sys.argv[2]
pattern = sys.argv[3]


# Load inventory from terraform
inventory = json.loads(os.popen("TF_STATE=./ terraform-inventory  --list").read())

# Get the media_server
server = inventory[tf_object][0]

# Fetch the URL
url = "http://" + server + uri
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
        print("Pattern : " + pattern + "not found in " + url)
        exit(1)
