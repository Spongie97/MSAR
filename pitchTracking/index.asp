<%@language=JScript%>
<% title="MATLAB File Listing" %>
<!--#include virtual="/jang/include/editfile.inc"-->
<%
function getMFileH1(fileName){
	fso = new ActiveXObject("Scripting.FileSystemObject");
	fid=fso.OpenTextFile(fileName, 1);
	lines=fid.ReadAll();
	fid.Close();
	
	pattern=/^%\s*\w+\s+(.*)/i;
	pattern=/^%\s*(.*)/i;
	lines=lines.split("\n");
	for (i=0; i<lines.length; i++){
		line=lines[i];
		found=line.match(pattern);
		if (found!=null)
			return(RegExp.$1);
	}
	return("");
}
%>
<html>
<head>
	<title><%=title%></title>
	<meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=big5">
	<meta HTTP-EQUIV="Expires" CONTENT="0">
<!--
	<style>
		td {font-family: "標楷體", "helvetica,arial", "Tahoma"}
		A:link {text-decoration: none}
		A:hover {text-decoration: underline}
	</style>
-->
</head>

<body background="/jang/graphics/background/yellow.gif">
<!font face="標楷體">
<h2 align=center><%=title%></h2>
<hr>

<table border=1 align=center>
<tr>
<th>File Name<th>H1 Help<th>Size
<%
fso = new ActiveXObject("Scripting.FileSystemObject");
fullPath = Server.MapPath(".");
fd = fso.GetFolder(fullPath);
fc = new Enumerator(fd.Files);
for (; !fc.atEnd(); fc.moveNext()){
	fileName=fc.item()+"";
	items=fileName.split(".");
	ext=items[items.length-1];
	if ((ext=="m")|(ext=="M")){
		f = fso.GetFile(fileName);
		Response.write("<tr>");
		Response.write("<td><a href=\"" + f.Name + "\">" + f.Name + "</a></td>");
		Response.write("<td>" + getMFileH1(fileName) + "&nbsp;</td>");
		Response.write("<td>" + f.Size + "</td>");
	}
}
%>
</table>

<hr>

<script language="JavaScript">
document.write("Last updated on " + document.lastModified + ".")
</script>

<a href="/jang/sandbox/asp/lib/editfile.asp?FileName=<%=Request.ServerVariables("PATH_INFO")%>"><img align=right border=0 src="/jang/graphics/invisible.gif"></a>
<!/font>
</body>
</html>
