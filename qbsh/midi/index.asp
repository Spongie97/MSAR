<% title=Request.ServerVariables("URL") %>
<!--#include virtual="/jang/include/editfile.inc"-->
<html>
<head>
	<title><%=title%></title>
	<meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=big5">
	<meta HTTP-EQUIV="Expires" CONTENT="0">
	<style>
		td {font-family: "標楷體", "helvetica,arial", "Tahoma"}
		A:link {text-decoration: none}
		A:hover {text-decoration: underline}
	</style>
</head>

<body background="/jang/graphics/background/yellow.gif">
<font face="標楷體">
<h2 align=center><%=title%></h2>
<hr>
<%
Set fs = Server.CreateObject("Scripting.FileSystemObject")
FullPath = Server.MapPath(".")
Set fd = fs.GetFolder(FullPath)
%>

<table border=1 align=center>
<tr>
<th>File name</th><th>Size (Bytes)</th><th>Last modified</th>
<%
for each f in fd.files
	ext=fs.GetExtensionName(f.name)
	if ext="mid" Or ext="MID" Then
		response.write("<tr align=center>")
		response.write("<td align=left><a target=_blank href=""" & f.name & """>" & f.name & "</a></td>")
		response.write("<td>" & f.size & "</td>")
		response.write("<td>" & f.DateLastModified & "</td>")
		response.write("<tr>")
	End If
next
%>
</table>
<%
set fs=nothing
set fd=nothing
%>

<hr>

<script language="JavaScript">
document.write("Last updated on " + document.lastModified + ".")
</script>

<a href="/jang/sandbox/asp/lib/editfile.asp?FileName=<%=Request.ServerVariables("PATH_INFO")%>"><img align=right border=0 src="/jang/graphics/invisible.gif"></a>
</font>
</body>
</html>
