# FILE: add_connectors.py
# DESC: Adds connectors to running router pods
#################################################
import time
import json
import httplib
import ssl
import os
import sys

TOKEN_FILE  = "/var/run/secrets/kubernetes.io/serviceaccount/token"
CONFIG_FILE = sys.argv[1]

IP=0 # Field to reference pod IP address
TS=1 # Field to reference pod timestamp

def retrieve_token():
  with open(TOKEN_FILE, 'r') as f:
    return f.read().replace('\n', '')

def api_request(host, port, path, token):
  ''' Makes REST request to API server and returns response'''
  context = ssl._create_unverified_context()
  conn = httplib.HTTPSConnection(host, port, timeout=5, context=context)
  conn._context.check_hostname = False
  conn._context.verify_mode = ssl.CERT_NONE
  #conn.set_debuglevel(1)

  headers = {}
  headers['Authorization'] = "Bearer %s" % token

  req = conn.request("GET", path , headers=headers)
  res = conn.getresponse()

  return res.read()

def extract_ips(response, label):
  ''' Given an API response, return list of pod ips ordered by pod start time'''
  pod_list = []
  js = json.loads(response)

  for pod in js['items']:
    # Filter non router pods
    if('application' in pod['metadata']['labels'] and
            pod['metadata']['labels']['application'] == label):
      if('podIP' not in pod['status']):
        print("Waiting for IP address...")
        return None
      ip = pod['status']['podIP']
      st = pod['status']['startTime']

      # Format timestamp so it can be sorted
      timestamp = time.strptime(st, '%Y-%m-%dT%H:%M:%SZ')
      pod_list.append([ip, timestamp])

  # sort pods in ascending order by timestamp
  pod_list.sort(key=lambda x: x[TS])

  return [pod[IP] for pod in pod_list]

def update_config(ip_list):
  ''' Adds connectors to all running router pods '''
  for ip in ip_list:
    CONNECTOR = ("connector {\n"
                 "  host: " + ip + "\n"
                 "  port: 55672\n"
                 "  role: inter-router\n"
                 "  verifyHostName: no\n"
                 "}\n\n"
                )
    with open(CONFIG_FILE, "a") as f:
      f.write(CONNECTOR)

host = os.environ['KUBERNETES_SERVICE_HOST']
port = os.environ['KUBERNETES_PORT_443_TCP_PORT']
ip   = os.environ['POD_IP']
ns   = os.environ['POD_NAMESPACE']
name = os.environ['APPLICATION_NAME']

path = "/api/v1/namespaces/" + ns + "/pods"
token = retrieve_token()
 
while True:
  # Send REST requests until other routers are ready
  response = api_request(host, port, path, token)
  ip_list  = extract_ips(response, name)
  time.sleep(1)
  if(ip_list is not None):
      break

# Get the ip addresses of the routers already running
si = ip_list.index(ip)
ip_list = ip_list[:si]

print("Connecting to: ")
print(ip_list)
update_config(ip_list)
