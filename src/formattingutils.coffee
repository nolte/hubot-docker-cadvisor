# Description:
#   util scirpt for formatting strings 
#
#
#
# Author:
#  nolte07
#
Intl = require('intl')


options = {
  year: 'numeric', month: 'numeric', day: 'numeric',
  hour: 'numeric', minute: 'numeric', second: 'numeric',
  hour12: false,
};
#https://developer.mozilla.org/de/docs/Web/JavaScript/Reference/Global_Objects/DateTimeFormat
dateTimeFormatter = new Intl.DateTimeFormat('de-DE',options); 

prettyFileSize = (bytes) ->
  # How to Format Raw Byte File Size into a Humanly Readable Value Using PHP
  # http://www.stemkoski.com/how-to-format-raw-byte-file-size-into-a-humanly-readable-value-using-php/
  n = Math.floor( Math.log(bytes) / Math.log(1024) )
  r = bytes / Math.pow(1024, n)
  r = Math.round( r * Math.pow(10, n - 1) ) / Math.pow(10, n - 1)
  return r + ['Byte','KB','MB','GB','TB'][n]

# find the latest Release version from a maven artifact
formatDateToHumanPrint = (date) ->
  dateTimeFormatter.format(date);
  
module.exports = {
  prettyFileSize : prettyFileSize
  formatDateToHumanPrint : formatDateToHumanPrint
  }

