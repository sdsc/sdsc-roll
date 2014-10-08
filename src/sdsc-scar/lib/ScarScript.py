#!/bin/env python

import commands
from optparse import OptionParser
import re
import sys

class ScarScript:
  """
  ScarScript - base class for SDSC Cluster Administration Resources python
               scripts.
  """

  VERSION = 1.0

  def do(self, command):
    """
    System command wrapper.  Prints command if self.quiet is False.  If
    self.debug is true, returns a constant; otherwise, executes command and
    returns its output.
    """
    if not self.quiet:
      print command
    if self.debug:
      return '42'
    else:
      result = commands.getoutput(command)
      if not self.quiet:
        print result
      return result

  def getNodeJobs(self, pattern, property=None):
    """
    Returns a dictionary of jobs that are running on each node that matches
    the specified pattern.  If not None, only nodes with the specified
    property are returned.  The node names serve as the keys of the returned
    dictionary; the values are arrays of strings of the format
    <jobid>/<user>/<queue>x<cores>.  The final element of each array contains
    the number of free cores.
    """
    result = { }
    command = "pbsnodes -l all | grep -E -- '\<%s\>' | awk ' {print $1}'" % pattern
    hosts = commands.getoutput(command).split("\n")
    if len(hosts) == 1 and hosts[0] == '':
      return result
    for host in hosts:
      result[host] = []
    qstatOutput = commands.getoutput("qstat -f")
    for pbsnodesOutput in commands.getoutput("pbsnodes -a").split("\n\n"):
      matchInfo = re.search(r'^([^\s]+)', pbsnodesOutput)
      if not matchInfo:
        continue
      host = matchInfo.group(1)
      if not result.has_key(host):
        continue
      if property and pbsnodesOutput.find(property) < 0:
        del result[host]
        continue
      matchInfo = re.search(r'np = (\d+)', pbsnodesOutput)
      unusedCores = 0
      if matchInfo:
        unusedCores = int(matchInfo.group(1))
      coresUsedByJob = { }
      matchInfo = re.search(r'jobs = ([^\n]+)', pbsnodesOutput, re.DOTALL)
      if matchInfo:
        for coreJob in re.split(', ?', matchInfo.group(1)):
          (core, jobId) = coreJob.split('/')
          if not coresUsedByJob.has_key(jobId):
            coresUsedByJob[jobId] = 0
          coresUsedByJob[jobId] += 1
          unusedCores -= 1
        for jobId in coresUsedByJob.keys():
          jobNumber = jobId.split('.')[0].split('[')[0]
          matchInfo = re.search(
            "Job Id: %s.*?Job_Owner = ([^@\\s]+).*?queue = ([^\\s]+)" % jobNumber, qstatOutput, re.DOTALL
          )
          jobOwner = "???"
          jobQueue = "???"
          if matchInfo:
            jobOwner = matchInfo.group(1)
            jobQueue = matchInfo.group(2)
          result[host].append(
            "%s/%s/%sx%s" % (jobId.split(".")[0], jobOwner, jobQueue, coresUsedByJob[jobId])
          )
      result[host].append(str(unusedCores))
    return result

  def parseArgs(self, valid):
    """
    Parses sys.argv according to the options listed in the valid array.  Each
    element of valid is a recognized command-line option, including initial
    dashes.  Options that require an argument should end with a colon and an
    optional type indicator (':s' for string ':i' for int).  The method
    provides support for the options -d, -h, -q, and -v (debug mode, help,
    quiet, and version).  The method returns a tuple consisting of a dictionary
    of option values and an array of any trailing positional arguments.
    """
    parser = OptionParser(
      add_help_option=False, version="%prog " + str(self.__class__.VERSION)
    )
    for arg in valid:
      colonPlace = arg.find(':')
      if colonPlace < 0:
        parser.add_option(arg, action='store_true')
      else:
        if arg[colonPlace:] == ':i':
          type = 'int'
        else:
          type = 'string'
        parser.add_option(arg[0:colonPlace], type=type)
    parser.add_option('-d', action="store_true")
    parser.add_option('-h', '--help', action="store_true")
    parser.add_option('-q', action="store_true")
    parser.add_option('-v', action="store_true")
    (options, args) = parser.parse_args()
    if options.help:
      help(self.__class__)
      sys.exit(0)
    if options.v:
      parser.print_version()
      sys.exit(1)
    self.debug = False
    self.quiet = False
    if options.q:
      self.quiet = True
    if options.d:
      self.debug = True
      self.quiet = False
    return (options, args)

  def ssh(self, host, command):
    """
    Returns the ssh command to run a given command on a given remote host.
    """
    result = '/usr/bin/ssh ' + host
    if not command:
      pass
    elif command.find('"') < 0:
      result += ' "' + command + '"'
    else:
      result += " '" + command + "'"
    return result
