<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Duplicati Reports</title>
<!--#include virtual="\_settings.inc"-->
</head>

<body>

<%
response.write("<PRE>")

dim report, reportLines, job, result, cmd1

set cmd1 = Server.CreateObject("ADODB.Command")
cmd1.ActiveConnection = conn

set rs=Server.CreateObject("ADODB.recordset")
cmd1.CommandText = "Select ip, report from reports where pk=?"
cmd1.Parameters(0) = request.QueryString("pk")
Set rs = cmd1.Execute()

response.write(rs("ip") + "<br>")
response.write(rs("report"))
rs.close
conn.close

%>
</pre>
</body>
</html>
