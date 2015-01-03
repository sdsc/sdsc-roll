#!/bin/env python

import commands
import os
import re
import sys
import ConfigParser

class PackageVersionCheck():
  """
  package-version-check.py - Check for new versions of roll software packages.

  package-version-check.py [-h] [--ini=path] [pattern ...]

    -h
      Print this text, then exit.

    --ini=path
      Path to ini file (see ConfigParser doc).  If not specified, the script
      looks for package-version-check.ini in the local and $HOME dirs.

    pattern ...
      List of patterns to match against paths to local package dirs.
      Defaults to '.' (i.e., matches all package dirs).

  Each section of the ini file has the name of a software package; within
  each section, these options are recognized:

    dir
      Path to the package directory; defaults to ${package}-roll/src/${package}

    dirformat
      Format for converting the groups of the dir match into a version.
      Defaults to $1.

    dirpat
      Regular expression that matches the text in version.mk that contains
      the local package version, where the version itself is contained within
      the first group.  Defaults to "\bVERSION\s*=\s*(\S+)".

    note
      General notes about the package to include in the script output.

    url
      URL to the web page that contains a reference to the package's latest
      version.  Required.

    urlformat
      Format for converting the groups of the URL match into a version.
      Defaults to $1.

    urlpat
      Regular expression that matches the text on the web page that contains
      the package version, where the version itself is contained within the
      first group.  Defaults to "$package-(\d+(?:\.\d+)*)\.(?:tar.*|tgz|zip),
      i.e., the package name followed by a dash, a package version consisting
      of one or more period-separated sets of digits, then a trailing period
      and compression extension.
  """

  monthNumber = {
    'jan':1, 'january':1,
    'feb':2, 'february':2,
    'mar':3, 'march':3,
    'apr':4, 'april':4,
    'may':5, 'may':5,
    'jun':6, 'june':6,
    'jul':7, 'july':7,
    'aug':8, 'august':8,
    'sep':9, 'september':9, 'sept':9,
    'oct':10, 'october':10,
    'nov':11, 'november':11,
    'dec':12, 'december':12,
  }

  def findlatestversion(self, text, pat, format):
    result = '0'
    for match in re.finditer(pat, text):
      thisversion = format
      for i in range(1, 99):
        try:
          if match.group(i) == None:
            continue
          thisversion = thisversion.replace('$%s' % i, match.group(i))
        except IndexError:
          break
      if self.versioncmp(result, thisversion) < 0:
        result = thisversion
    if result == '0':
      return ''
    return result

  def versioncmp(self, v1, v2):
    piecevalue = lambda x: \
      int(x) if x.isdigit() else \
      PackageVersionCheck.monthNumber[x.lower()] if PackageVersionCheck.monthNumber.has_key(x.lower()) \
      else x
    pieces1 = [piecevalue(x) for x in re.findall(r'\d+|[a-zA-Z]+', v1)]
    pieces2 = [piecevalue(x) for x in re.findall(r'\d+|[a-zA-Z]+', v2)]
    return cmp(pieces1, pieces2)

  def __init__(self):

    iniPath = None
    packagePat = None
    for arg in sys.argv[1:]:
      if arg == '-h':
        help(PackageVersionCheck)
        sys.exit(0)
      elif arg.startswith('--ini='):
        iniPath=arg[6:]
      else:
        if packagePat:
          packagePat += '|' + arg
        else:
          packagePat = arg

    if not iniPath:
      iniPath = os.environ['HOME'] + '/package-version-check.ini'
      if os.path.isfile('./package-version-check.ini'):
        iniPath = './package-version-check.ini'

    if not os.path.isfile(iniPath):
      print 'ini file %s not found' % iniPath
      sys.exit(2)

    packageinfo = ConfigParser.ConfigParser()
    packageinfo.read(iniPath)

    if not packagePat:
      packagePat = '.'

    for package in sorted(packageinfo.sections()):

      dir = '%s-roll/src/%s' % (package, package)
      if packageinfo.has_option(package, 'dir'):
        dir = packageinfo.get(package, 'dir')
      if not re.search(packagePat, dir):
        continue

      dirpat = r'\bVERSION\s*=\s*(\S+)'
      if packageinfo.has_option(package, 'dirpat'):
        dirpat = packageinfo.get(package, 'dirpat')
      dirformat = '$1'
      if packageinfo.has_option(package, 'dirformat'):
        dirformat = packageinfo.get(package, 'dirformat')
      url = packageinfo.get(package, 'url')
      urlpat = r'%s-(\d+(?:\.\d+)*)\.(?:tar.*|tgz|zip)' % package
      if packageinfo.has_option(package, 'urlpat'):
        urlpat = packageinfo.get(package, 'urlpat')
      urlformat = '$1'
      if packageinfo.has_option(package, 'urlformat'):
        urlformat = packageinfo.get(package, 'urlformat')

      currentversion = self.findlatestversion(
        commands.getoutput('/bin/cat %s/version.mk 2>&1' % dir),
        dirpat, dirformat
      )
      if currentversion == '':
        currentversion = 'unknown'
      latestversion = self.findlatestversion(
        commands.getoutput("/usr/bin/curl --insecure '%s' 2>&1" % url),
        urlpat, urlformat
      )
      if latestversion == '':
        latestversion = 'unknown'

      note = ''
      if packageinfo.has_option(package, 'note'):
        note = '; note: %s' % packageinfo.get(package, 'note')

      if self.versioncmp(currentversion, latestversion) == 0:
        print "%s/%s: local version '%s' is up to date%s" % (dir, package, currentversion, note)
      else:
        print "%s/%s: local version '%s'; latest version '%s'%s" % (dir, package, currentversion, latestversion, note)

PackageVersionCheck()
