<%
Function GetDBConnection()
    Dim connString, conn
    
    connString = "Provider=SQLOLEDB;Data Source=localhost\SQLEXPRESS;Initial Catalog=projeto_db;Integrated Security=SSPI;"

    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open connString
    
    Set GetDBConnection = conn
End Function
%>