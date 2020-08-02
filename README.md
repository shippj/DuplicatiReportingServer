# Duplicati Reporting Server

This will collect reports from Duplicati, write them to a SQL database, then show you which backups have quit working.

To setup duplicati to send these reports:
open duplicati, settings, default options, and add these options:

--send-http-url=http://duplicati.example.com
--send-http-any-operation=true
--send-http-message-parameter-name=message
--send-http-level=all
--send-http-message=Duplicati %OPERATIONNAME% report for %backup-name%   %PARSEDRESULT%   %RESULT%

(Replace "duplicati.example.com" with the hostname or IP number of your web server.)

On your SQL server, execute database.sql

On your web server, create a new site and put all the files from this project in the sites folder.

Modify the _settings.inc file as needed if your sql server isn't running on the same machine as your web server

When you view the root of your site (http://duplicati.example.com), you should see the current date/time, and your IP number.  If not, you don't have your IIS settings correct, or your DSN in the _settings.inc file isn't correct.  Check your site's log, and windows event viewer for troubleshooting clues.

Run a backup in duplicati to generate a report, then view it with:
http://duplicati.example.com/summary.asp

enjoy!

