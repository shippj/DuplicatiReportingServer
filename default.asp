<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Duplicati Report Receiver</title>
<!--#include virtual="\_settings.inc"-->
</head>

<body>
<%
response.write(now)
response.write("<BR>")

' GET IP NUMBER (HTTP_CF_CONNECTING_IP is in case we are behind cloudflare)
if Request.ServerVariables ("HTTP_CF_CONNECTING_IP")="" then
	ip = Request.ServerVariables("REMOTE_ADDR")
else
	ip = Request.ServerVariables ("HTTP_CF_CONNECTING_IP")
end if
response.write(ip)

' RECEIVE REPORT
dim report, reportLines, job, result
report = Request.Form("message")
if (report = "") then response.End

response.write("Saving Data...<br>")

' PARSE OUT THE JOB NAME
reportLines = Split(report,vbCrLF)
If UBound(reportLines) = 0 Then	reportLines = Split(report,vbLf) 	' probably from MAC OS

If UBound(reportLines) > 0 Then 
	job = reportLines(0)
else
	job = "(null)"
end if

' if the job name has 3 spaces, truncate it there.  i don't know why some jobs have line returns and others dont
eol = instr(job,"   ")
if eol>0 then job = left(job,eol)

if (instr(report, "ParsedResult: Success")) then
	result="S"
elseif (instr(report, "ParsedResult: Warning")) then
	result="W"
else
	result="E"
end if


' WRITE TO SQL
Dim cmd1
Set cmd1 = Server.CreateObject("ADODB.Command")    
cmd1.ActiveConnection = conn
cmd1.CommandText = "insert into reports ([Date], [Time], [Job], [Report], [Success], [IP]) values (getdate(), getdate(), ?, ?, ?, ?)"
cmd1.Parameters(0) = job
cmd1.Parameters(1) = report
cmd1.Parameters(2) = result
cmd1.Parameters(3) = ip
cmd1.execute
conn.close

%>
<br>Data Saved...
</body>
</html>
