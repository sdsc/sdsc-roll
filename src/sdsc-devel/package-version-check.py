#!/bin/env python

import commands
import re
import sys
import ConfigParser

class PackageVersionCheck():
  """
  PackageVersionCheck - Check for updated versions of roll software packages.
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

    packageinfo = ConfigParser.ConfigParser()
    packageinfo.read('package-version-check.ini')

    if (len(sys.argv) > 1):
      packagelist = sys.argv[1:]
    else:
      packagelist = sorted(packageinfo.sections())

    for package in packagelist:

      if not packageinfo.has_section(package):
        print "%s: Not listed in package file" % package
        continue

      dir = '%s-roll/src/%s' % (package, package)
      if packageinfo.has_option(package, 'dir'):
        dir = packageinfo.get(package, 'dir')
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
      latestversion = self.findlatestversion(
        commands.getoutput("/usr/bin/curl '%s' 2>&1" % url), urlpat, urlformat
      )
      if currentversion == '':
        if packageinfo.has_option(package, 'dirfail'):
          currentversion = packageinfo.get(package, 'dirfail')
        else:
          currentversion = 'unknown'
      if latestversion == '':
        if packageinfo.has_option(package, 'urlfail'):
          latestversion = packageinfo.get(package, 'urlfail')
        else:
          latestversion = 'unknown'

      note = ''
      if packageinfo.has_option(package, 'note'):
        note = '; note: %s' % packageinfo.get(package, 'note')

      if self.versioncmp(currentversion, latestversion) == 0:
        print "%s: local version '%s' is up to date%s" % (package, currentversion, note)
      else:
        print "%s: local version '%s'; latest version '%s'%s" % (package, currentversion, latestversion, note)

PackageVersionCheck()
