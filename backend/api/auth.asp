<% @Language=VBScript %>
 <%
 Option Explicit
 Response.ContentType = "application/json"
 Response.CharSet = "UTF-8"

 Dim conn, oJSON, jsonString, data, action, cmd, rs
 Dim name, email, password_hash, token, userId

 Set oJSON = New JSON

 Function getRequestBody()
     Dim bs : Set bs = CreateObject("ADODB.Stream")
     bs.Type = 1
     bs.Open
     bs.Write Request.BinaryRead(Request.TotalBytes)
     bs.Position = 0
     bs.Type = 2
     bs.Charset = "UTF-8"
     Dim strBody : strBody = bs.ReadText
     bs.Close
     Set bs = Nothing
     getRequestBody = strBody
 End Function

 action = LCase(Request.QueryString("action"))
 jsonString = getRequestBody()

 If (action = "register" or action = "login") and jsonString = "" Then
     Response.Status = 400
     Response.Write "{""success"": false, ""message"": ""Corpo da requisição não pode ser vazio.""}"
     Response.End
 End If

 If jsonString <> "" Then
     Set data = oJSON.parse(jsonString)
 End If

 Set conn = GetDBConnection()

 Select Case action
     Case "register"
         name = data.item("name")
         email = data.item("email")
         password_hash = data.item("password")

         Set cmd = Server.CreateObject("ADODB.Command")
         cmd.ActiveConnection = conn
         cmd.CommandText = "add_user"
         cmd.CommandType = 4
         
         cmd.Parameters.Append cmd.CreateParameter("@name", 200, 1, 100, name)
         cmd.Parameters.Append cmd.CreateParameter("@email", 200, 1, 100, email)
         cmd.Parameters.Append cmd.CreateParameter("@password_hash", 200, 1, 255, password_hash)
         
         Set rs = cmd.Execute

         If Not rs.EOF Then
             If rs("success") = 1 Then
                 Response.Write "{""success"": true, ""message"": ""usuário registrado com sucesso""}"
             Else
                 Response.Status = 400
                 Response.Write "{""success"": false, ""message"": """ & rs("message") & """}"
             End If
         End If

     Case "login"
 End Select 

 On Error Resume Next
 If IsObject(rs) Then
     If rs.State = 1 Then rs.Close
     Set rs = Nothing
 End If
 If IsObject(conn) Then
     If conn.State = 1 Then conn.Close
     Set conn = Nothing
 End If
 Set cmd = Nothing
 Set oJSON = Nothing
 On Error Goto 0
 %>