#!/usr/bin/python
# FILE: configure.py
# VERS: Python 2
# DESC: Configures qdrouterd.conf file with the attribute
#       values specified by the environmental variables
#
###########################################################
import os

fname = "/etc/qpid-dispatch/qdrouterd.conf"
out = "out"

SECTION_VARS = ["ROUTER", "SSLPROFILE", "AUTHSERVICEPLUGIN", "LISTENER", "CONNECTOR", "LOG",
                "ADDRESS", "LINKROUTE", "AUTOLINK", "CONSOLE", "POLICY", "VHOST"]

config = []
comments = []

SECT = 0
ATTR = 1
ATTR_NAME = 0
ATTR_VALUE = 1

ENV = [e for e in os.environ if e.split("_")[SECT] in SECTION_VARS]

def read_config(fname):
  ''' Read Configuration file into multi-dimension list for easier manipulation '''
  in_section = False
  with open(fname, 'r') as fin:
    for line in fin:
      if(line[0] ==  "#"):
        comments.append(line)
      else:
        line = line.split("\n")
        line = ''.join(filter(lambda x: x != "", line))
        if("{" in line):
          section = [line.split(" ")[0], []]
          in_section = True
        elif("}" in line):
          config.append(section)
          in_section = False
        elif(in_section):
          attr = line.split(":")
          attr = [x.strip() for x in attr]
          section[ATTR].append(attr)
  fin.close()
  # print config
  # for c in config:
  #   print c[0]
  #   for i in c[1]:
  #     print "    ", i

def update_config():
  ''' Update configuration list with environment variable attributes'''
  for e in ENV:
    sect, attr = e.split("_")
    for s in config:
      for a in s[ATTR]:
        if(a[ATTR_NAME].upper() == attr):
          a[ATTR_VALUE] = os.environ.get(e)

def write_config(fname):
  ''' Overwrite qdrouter.conf with new attributes and sections'''
  fh = open(fname, "w")
  for c in comments:
    fh.write(c)
  fh.write("\n")
  for c in config:
    fh.write(c[SECT] + " {\n")
    for i in c[ATTR]:
      fh.write("    " + ": ".join(i) + "\n")
    fh.write("}\n\n")
  fh.close()

#with open(out, 'r') as fin:
#    print fin.read()

read_config(fname)
update_config()
write_config(fname)
