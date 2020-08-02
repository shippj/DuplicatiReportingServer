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

' ARE WE BEING VIEWED FROM A PHONE?  IF SO, SHOW LESS DATA
ua = Request.ServerVariables ("HTTP_USER_AGENT")
'response.write ua & "<br>"
If (instr(ua,"Android")>0) then
	ShowDays=1
else
	ShowDays=10
end if

dim report, reportLines, job, result, company, cmd1
set cmd1 = Server.CreateObject("ADODB.Command")
cmd1.ActiveConnection = conn



' PREPARE SQL CONNECTIONS
set rs=Server.CreateObject("ADODB.recordset")
set rs2=Server.CreateObject("ADODB.recordset")

response.write(DateAdd("d",1,Now()))

' HIDE
if (request.QueryString("hide")<>"") then
	if (request.QueryString("w")<>"") then
		cmd1.CommandText = "insert into hide ([date],[job]) values (?, ?)"
		cmd1.Parameters(0) = DateAdd("ww",request.QueryString("w"),date())
		cmd1.Parameters(1) = request.QueryString("hide")
		cmd1.execute()	
	else
		cmd1.CommandText = "update reports set hide=1 where job=?"
		cmd1.Parameters(0) = request.QueryString("hide")
		cmd1.execute()
	end if
end if



' COUNT
rs.Open "Select top 10 [date],count(*), count(distinct job) from reports WHERE job like 'Duplicati Backup report %' group by [date] order by [date] desc", conn %>
<table border=1><tr>
<th>Date</th>
<th>Report Count</td>
<th>Distinct Job Count</td>
</tr> <%
Do until rs.eof
	response.write("<tr><td>" & rs("date") & "</td>")
	response.Write("<td>"&rs(1)&"</td>")
	response.Write("<td>"&rs(2)&"</td></tr>")
	rs.movenext
Loop 
rs.close
Response.Flush




' FAILING
rs.Open "SELECT max([Date]) as MaxDate, [Job]  FROM [Duplicati].[dbo].[Reports] where hide is null and success<>'E' and [Job] like 'Duplicati Backup Report%' group by Job  having datediff(day,max([Date]),getdate())>3 order by MaxDate desc", conn %>
</table><br><table border=1><tr>
<th>Last Date</th>
<th>Jobs failed or missing for over 3 days</td>
</tr> <%
Do until rs.eof

    ' CHECK TO SEE IF WE HAVE HIDDEN THIS ONE
		cmd1.CommandText = "SELECT count(*) from hide where [date]>getdate() and job=?"
		cmd1.Parameters(0) = rs("job")
		Set rs2 = cmd1.Execute()
		if (rs2(0)=0) then
			response.write("<tr><td>" & rs("MaxDate") & "</td><td>" & rs("Job") & " [Forget - ")
			response.write(" <a href='summary.asp?w=1&hide=" & rs("Job") & "'>1W</a> - ")
			response.write(" <a href='summary.asp?w=2&hide=" & rs("Job") & "'>2W</a> - ")
			response.write(" <a href='summary.asp?w=4&hide=" & rs("Job") & "'>1M</a> - ")
			response.write(" <a href='summary.asp?w=8&hide=" & rs("Job") & "'>2M</a> - ")
			response.write(" <a href='summary.asp?w=16&hide=" & rs("Job") & "'>4M</a> - ")
			response.write(" <a href='summary.asp?w=32&hide=" & rs("Job") & "'>8M</a>] - ")
			response.write(" <a href='summary.asp?hide=" & rs("Job") & "'>Forever</a>")
		end if
		OldestRecordWeNeedToKeep = rs("MaxDate")	' FOR THE CLEANUP FUNCTION
		rs2.close

response.write("</td></tr>")
	rs.movenext
Loop
rs.close
Response.Flush



' LAST 3 days of failures
	rs.Open "Select * from reports WHERE datediff(day,[Date],getdate())<=3 and success='E' order by pk desc", conn %>
	</table><br><table border=1><tr>
	<th>Date</th>
	<th>Time</th>
	<th>Last 3 days of failures</td>
	</tr> <%
	Do until rs.eof
		response.write("<tr><td>" & rs("date") & "</td><td>" & rs("time") & "</td><td>")
		response.Write("<a href=""report.asp?pk="&rs("pk")&"""><span style=""color: red"">" & rs("job") & "</span></a>")
		response.write("</td></tr></span>")
		rs.movenext
	Loop
	rs.close
Response.Flush



' LAST X days
rs.Open "Select * from reports WHERE datediff(day,[Date],getdate())<="&ShowDays&" order by pk desc", conn %>
</table><br><table border=1><tr>
<th>Date</th>
<th>Time</th>
<th>Last <%=ShowDays%> days</td>
</tr> <%
Do until rs.eof
	response.write("<tr><td>" & rs("date") & "</td><td>" & rs("time") & "</td><td>")
	If (rs("Success") = "E") then
		color="red"
	elseIf (rs("Success") = "W") then
		color="teal"
	elseIf (rs("Success") = "S") then
		color="blue"
	else
		color="black"
	end if	
	response.Write("<a href=""report.asp?pk="&rs("pk")&"""><span style=""color: "&color&""">" & rs("job") & "</span></a>")
	response.write("</td></tr></span>")
	rs.movenext
Loop
rs.close
response.write("</table>")
Response.Flush


'CLEANUP
	response.write("Deleting old reports...<br>")
	OldestRecordWeNeedToKeep = DateAdd("ww",-2,OldestRecordWeNeedToKeep)
	sql = "delete from reports where [date] < '" & CStr(OldestRecordWeNeedToKeep) & "'"
	conn.execute(sql)

	response.write("Deleting old hide records...<br>")
	sql = "delete from hide where [date] < getdate()"
	conn.execute(sql)
	response.write("Done!<br>")




conn.close %>
</body>
</html>
