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
'response.write(now)
'response.write("<BR>")

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



'COMPANY NAME
company = Request.QueryString("company")
if company = "" then
	response.write "missing company number!"
	response.end
elseif company=1234 then
	company=" and [Job] like '%for walmart %' "
elseif company=9898 then
	company=" and 1=1"
else
	response.write "invalid company number!"
	response.end
end if



' PREPARE SQL CONNECTIONS
set rs=Server.CreateObject("ADODB.recordset")
set rs2=Server.CreateObject("ADODB.recordset")

response.write(DateAdd("d",1,Now()))

' HIDE
if (request.QueryString("hide")<>"") then
	if (request.QueryString("d")<>"") then
		cmd1.CommandText = "insert into hide ([date],[job]) values (?, ?)"
		cmd1.Parameters(0) = DateAdd("y",request.QueryString("d"),date())
		cmd1.Parameters(1) = request.QueryString("hide")
		response.write("<br>Hiding Till "&cmd1.Parameters(0))
		cmd1.execute()	
	else
		cmd1.CommandText = "update reports set hide=1 where job=?"
		cmd1.Parameters(0) = request.QueryString("hide")
		cmd1.execute()
	end if
end if



' COUNT
rs.Open "Select top 10 [date],count(*), count(distinct job) from reports WHERE job like 'Duplicati Backup report %' "&company&" group by [date] order by [date] desc", conn %>
<table border=1><tr>
<th>Date</th>
<th>Report Count</td>
<th>Distinct Job Count</td>
</tr> <%
Do until rs.eof
	response.write("<tr><td>" & rs("date") & "</td>")
	response.Write("<td>"&rs(1)&"</td>")
	response.Write("<td>"&rs(2)&"</td></tr>"&vbcrlf)
	rs.movenext
Loop 
rs.close
Response.Flush




' FAILING
rs.Open "SELECT max([Date]) as MaxDate, [Job]  FROM [Duplicati].[dbo].[Reports] where hide is null and success<>'E' and [Job] like 'Duplicati Backup Report%' "&company&" group by Job  having datediff(day,max([Date]),getdate())>3 order by MaxDate desc", conn %>
</table><br><table border=1><tr>
<th>Last Date</th>
<th>Jobs failed or missing for over 3 days</td>
<th>Hide for X days</th>
</tr> <%
Do until rs.eof
	if (company=" and 1=1") then
		' CHECK TO SEE IF WE HAVE HIDDEN THIS ONE
		cmd1.CommandText = "SELECT count(*) from hide where [date]>getdate() and job=?"
		cmd1.Parameters(0) = rs("job")
		Set rs2 = cmd1.Execute()
		if (rs2(0)=0) then
			response.write("<tr><td>" & rs("MaxDate") & "</td>")
			response.write("<td>" & rs("Job") & "</td>")

			SuggestedDaysToHide = DateDiff("d",rs("MaxDate"),now)
			response.write("<td><form action=?> <input type=text size=4 name=d value=" & SuggestedDaysToHide & "> <input type=hidden name=company value=9898> <input type=hidden name=hide value='"& rs("Job") & "'> </form></td>")

			response.write("<td><a href='?company=9898&hide=" & rs("Job") & "'>Forever</a></td></tr>"&vbcrlf)
		end if
		OldestRecordWeNeedToKeep = rs("MaxDate")	' FOR THE CLEANUP FUNCTION
		OldestJobWeNeedToKeep = rs("Job")		' FOR THE CLEANUP FUNCTION
		rs2.close
	else
		response.write("<tr><td>" & rs("MaxDate") & "</td><td>" & rs("Job") & "</td></tr>"&vbcrlf)
	end if
	rs.movenext
Loop
rs.close
Response.Flush



' LAST 3 days of failures
if (company=" and 1=1") then
	rs.Open "Select * from reports WHERE datediff(day,[Date],getdate())<=3 "&company&" and success='E' order by pk desc", conn %>
	</table><br><table border=1><tr>
	<th>Date</th>
	<th>Time</th>
	<th>Last 3 days of failures</td>
	</tr> <%
	Do until rs.eof
		response.write("<tr><td>" & rs("date") & "</td><td>" & rs("time") & "</td><td>")
		response.Write("<a href=""report.asp?pk="&rs("pk")&"""><span style=""color: red"">" & rs("job") & "</span></a>")
		response.write("</td></tr></span>"&vbcrlf)
		rs.movenext
	Loop
	rs.close
end if
Response.Flush



' LAST X days
rs.Open "Select * from reports WHERE datediff(day,[Date],getdate())<="&ShowDays&" "&company&" order by pk desc", conn %>
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
	response.write("</td></tr></span>"&vbcrlf)
	rs.movenext
Loop
rs.close
response.write("</table>")
Response.Flush


'CLEANUP
if (company=" and 1=1") then
	response.write("Deleting old reports...<br>")
	OldestRecordWeNeedToKeep = DateAdd("ww",-2,OldestRecordWeNeedToKeep)
	sql = "delete from reports where [date] < '" & CStr(OldestRecordWeNeedToKeep) & "'"
	response.write(sql+"<br>")
	response.write(OldestJobWeNeedToKeep+"<br>")
	conn.execute(sql)

	response.write("Deleting old hide records...<br>")
	sql = "delete from hide where [date] < getdate()"
	conn.execute(sql)
	response.write("Done!<br>")
end if



conn.close %>
</body>
</html>
