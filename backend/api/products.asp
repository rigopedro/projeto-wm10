<!--#include file="../includes/db.asp"-->
<!--#include file="../includes/json.class.asp"-->
<% @Language=VBScript %>
<%
Option Explicit
Response.ContentType = "application/json"
Response.CharSet = "UTF-8"

Dim conn, oJSON, jsonString, data, method, cmd, rs
Dim productId, name, description, price, stock, searchTerm
Dim responseObj, productObj, productsArr
Dim token, authHeader, isValid

Set oJSON = New JSON
Set conn = GetDBConnection()

authHeader = Request.ServerVariables("HTTP_AUTHORIZATION")
isValid = False

If Len(authHeader) > 7 And LCase(Left(authHeader, 7)) = "bearer " Then
    token = Mid(authHeader, 8)
    
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conn
    cmd.CommandText = "SELECT dbo.fn_validate_token(?)"
    cmd.Parameters.Append cmd.CreateParameter("@token", 200, 1, 255, token)
    Set rs = cmd.Execute
    
    If Not rs.EOF Then
        If rs(0) = 1 Then
            isValid = True
        End If
    End If
    rs.Close
    Set rs = Nothing
    Set cmd = Nothing
End If

If Not isValid Then
    conn.Close
    Set conn = Nothing
    Response.Status = 401
    Response.Write "{""success"": false, ""message"": ""Acesso não autorizado. Token inválido ou ausente.""}"
    Response.End
End If

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

method = Request.ServerVariables("REQUEST_METHOD")
jsonString = getRequestBody()

If jsonString <> "" Then
    Set data = oJSON.parse(jsonString)
End If

Select Case method
    Case "GET"
        productId = Request.QueryString("id")
        searchTerm = Request.QueryString("search")
        
        If productId <> "" Then
            Set cmd = Server.CreateObject("ADODB.Command")
            cmd.ActiveConnection = conn
            cmd.CommandText = "sp_get_product_by_id"
            cmd.CommandType = 4
            cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , CInt(productId))
            Set rs = cmd.Execute

            If Not rs.EOF Then
                Set productObj = oJSON.create()
                productObj.add "id", rs("id")
                productObj.add "name", rs("name")
                productObj.add "description", rs("description")
                productObj.add "price", rs("price")
                productObj.add "stock", rs("stock")
                Response.Write oJSON.stringify(productObj)
            Else
                Response.Status = 404
                Response.Write "{""success"": false, ""message"": ""Produto não encontrado.""}"
            End If
        Else
            Set cmd = Server.CreateObject("ADODB.Command")
            cmd.ActiveConnection = conn
            cmd.CommandText = "sp_get_all_products"
            cmd.CommandType = 4
            cmd.Parameters.Append cmd.CreateParameter("@search_term", 200, 1, 100, searchTerm)
            Set rs = cmd.Execute
            
            Set productsArr = oJSON.createArray()
            While Not rs.EOF
                Set productObj = oJSON.create()
                productObj.add "id", rs("id")
                productObj.add "name", rs("name")
                productObj.add "description", rs("description")
                productObj.add "price", rs("price")
                productObj.add "stock", rs("stock")
                productsArr.push productObj
                rs.MoveNext
            Wend
            Response.Write oJSON.stringify(productsArr)
        End If

    Case "POST"
        name = data.item("name")
        description = data.item("description")
        price = data.item("price")
        stock = data.item("stock")
        
        Set cmd = Server.CreateObject("ADODB.Command")
        cmd.ActiveConnection = conn
        cmd.CommandText = "sp_add_product"
        cmd.CommandType = 4
        cmd.Parameters.Append cmd.CreateParameter("@name", 200, 1, 150, name)
        cmd.Parameters.Append cmd.CreateParameter("@description", 202, 1, -1, description)
        cmd.Parameters.Append cmd.CreateParameter("@price", 6, 1, , CDbl(price))
        cmd.Parameters.Append cmd.CreateParameter("@stock", 3, 1, , CInt(stock))
        Set rs = cmd.Execute

        Response.Status = 201
        Response.Write "{""success"": true, ""message"": ""Produto criado com sucesso."", ""new_id"": " & rs("new_id") & "}"

    Case "PUT"
        productId = Request.QueryString("id")
        name = data.item("name")
        description = data.item("description")
        price = data.item("price")
        stock = data.item("stock")

        Set cmd = Server.CreateObject("ADODB.Command")
        cmd.ActiveConnection = conn
        cmd.CommandText = "sp_update_product"
        cmd.CommandType = 4
        cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , CInt(productId))
        cmd.Parameters.Append cmd.CreateParameter("@name", 200, 1, 150, name)
        cmd.Parameters.Append cmd.CreateParameter("@description", 202, 1, -1, description)
        cmd.Parameters.Append cmd.CreateParameter("@price", 6, 1, , CDbl(price))
        cmd.Parameters.Append cmd.CreateParameter("@stock", 3, 1, , CInt(stock))
        cmd.Execute

        Response.Write "{""success"": true, ""message"": ""Produto atualizado com sucesso.""}"
        
    Case "DELETE"
        productId = Request.QueryString("id")

        Set cmd = Server.CreateObject("ADODB.Command")
        cmd.ActiveConnection = conn
        cmd.CommandText = "sp_delete_product"
        cmd.CommandType = 4
        cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , CInt(productId))
        cmd.Execute

        Response.Write "{""success"": true, ""message"": ""Produto deletado com sucesso.""}"

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