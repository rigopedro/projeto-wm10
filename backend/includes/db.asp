<%
Function GetDBConnection()
    Dim connString, conn
    connString = "Provider=SQLOLEDB;Data Source=localhost\SQLEXPRESS;Initial Catalog=projeto_db;User ID=api_user;Password=apisenha123;"
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open connString
    
    Set GetDBConnection = conn
End Function
%>