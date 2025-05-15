<%--
***************************************************************************************************************
DESCRIPCION: Formulario de detalle de reposicion Simcard
MODIFICADO POR: Cima-Manuel Marín S. 
MOTIVO DE MODIFICACIÓN: Se agrego el panel Empresarial para la actualizacion al momento de revisar un trámite
con los campos de fecha de entrega, hora de entrega, factura,guia de remision y recibido por.
FECHA DE MODIFICACIÓN: 20/05/2014
***************************************************************************************************************
***************************************************************************************************************
DESCRIPCION: Formulario de detalle de reposicion Simcard
MODIFICADO POR: Cima Galo Ortiz C. 
MOTIVO DE MODIFICACIÓN: Se cambia la propiedad del panel de soporte empresarial ya que antes se ocultaba 
                        dependiendo del rol del usuario y ahora se habilita o deshabilita.
FECHA DE MODIFICACIÓN: 28/05/2014
***************************************************************************************************************
***************************************************************************************************************
DESCRIPCION: Formulario de detalle de reposicion Simcard
MODIFICADO POR: Cima Galo Ortiz C. 
MOTIVO DE MODIFICACIÓN: Se realizan las siguientes mejoras
                        = Ingreso de simcard’s desde un nuevo panel en este formulario (Para 
                          no usar el link existente Modificar Tramite)
                        = Mejorar presentación de teléfono, motivo y tipo de simcard de las 
                          líneas para la reposición
                        = Permitir la actualización de datos del trámite (factura, guía de 
                          remisión, recibido por y fecha de entrega) aun cuando el trámite se 
                          encuentre en estado ACTIVO
                        = Especificar las líneas de las reposiciones de simcard en la alerta 
                          del mail al cliente
                        = Setear automaticamente la fecha de entrega con la fecha del sistema
                        = Permitir ingresar los minutos en los que se entrega las simcard's
FECHA DE MODIFICACIÓN: 30/06/2014
***************************************************************************************************************
***************************************************************************************************************
DESCRIPCION: Formulario de detalle de reposicion Simcard
MODIFICADO POR: Cima Galo Ortiz C. 
MOTIVO DE MODIFICACIÓN: Se ajustan datos del tramite para asemejar con los ingresados desde la WEB
FECHA DE MODIFICACIÓN: 17/07/2014
***************************************************************************************************************
***************************************************************************************************************
DESCRIPCION: [22735] - Reposicion SIMCARD corporativo
MODIFICADO POR: SUD. GVillanueva
MOTIVO DE MODIFICACIÓN: No permitir modificaciones en estado pendiente (X) y canacelado (C)
FECHA DE MODIFICACIÓN: 14/07/2023
***************************************************************************************************************
--%>
<%--RAR 20161207 se agrega nueva opción llamada stock de simcard con valor S--%>


<%@ Page Language="VB" MaintainScrollPositionOnPostback="true" StylesheetTheme="white" %>


<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
              
        Dim tramite As String = ""
        tramite = CType(FormView1.FindControl("Literal18"), Literal).Text
        If User.Identity.IsAuthenticated Then
            Dim strClientIP As String
            strClientIP = Request.UserHostAddress()
            ip.Value = strClientIP
            
            FormView1.Visible = True
            GridView1.Visible = True
            permiso.Visible = False
            'INICIO - CIM GORTIZ - 28/05/2014 - cambio propiedad enable por visible
            If User.IsInRole("Administrador") Or User.IsInRole("APL Reposicion Soporte") Then
                'pnl_soporte_empresarial.Visible = True
                pnl_soporte_empresarial.Enabled = True
                pnl_DetalleSolicitud.Enabled = True
            Else
                'pnl_soporte_empresarial.Visible = False
                pnl_soporte_empresarial.Enabled = False
                pnl_DetalleSolicitud.Enabled = False
            End If
            'FIN - CIM GORTIZ - 28/05/2014 - cambio propiedad enable por visible
        Else
            permiso.Visible = True
            FormView1.Visible = False
            GridView1.Visible = False
            pnl_soporte_empresarial.Enabled = False
            pnl_DetalleSolicitud.Enabled = False
        End If
        
        If Not Page.IsPostBack Then
            Me.Valida_Campo()
        End If
    End Sub
     
    Protected Sub FormView1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        If DataBinder.Eval(FormView1.DataItem, "ultimo_estado").ToString = "I" Or DataBinder.Eval(FormView1.DataItem, "ultimo_estado").ToString = "P" Or DataBinder.Eval(FormView1.DataItem, "ultimo_estado").ToString = "F" Or DataBinder.Eval(FormView1.DataItem, "ultimo_estado").ToString = "E" Then
            If User.IsInRole("Administrador") Or User.IsInRole("APL Reposicion Sim") Then
                modifica.NavigateUrl = "etapa.aspx?id_sim=" & DataBinder.Eval(FormView1.DataItem, "id_proc").ToString
                modifica.Visible = True
            End If
        End If
    End Sub
    
    'Inicio Proyecto [8957]
    Protected Sub btn_guardar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        '------- DATOS SRE - PRODUCCCION --------
        Dim idInsta As String = "9172"
        Dim IdtipoTran As String = "300011"
        Dim Integ As String = "100"
        Dim CodAlterno As String = "987620"
        Dim Us As String = "RSIMCARD"
        Dim Clav As String = "IF3886"
        Dim sreDS As String = "jdbc/axis"
        
        '------- DATOS SRE - DESARROLLO --------
        'Dim idInsta As String = "100032"
        'Dim IdtipoTran As String = "666788"
        'Dim Integ As String = "100065"
        'Dim CodAlterno As String = "987650"
        'Dim Us As String = "RSIMCARD"
        'Dim Clav As String = "IF3886"
        'Dim sreDS As String = "jdbc/axisdesa"
        
        Me.Mensaje_Error.Text = ""
        
        Dim correo As String = ""
        Dim tramite As String = ""
        Dim consult As String = ""
        Dim medio As String = ""
        Dim observacion As String = ""
        Dim fact As String = txt_factura.Text
        Dim fecha As String = txt_fecha_i.Text
        
        If Me.txt_fecha_i.Text = "" Then
            Me.Mensaje_Error.Text = "Por favor ingrese la fecha para poder continuar"
            Me.Mensaje_Error.ForeColor = Drawing.Color.Red
            Exit Sub
        End If
        
        If Me.txt_factura.Text = "" Then
            Me.Mensaje_Error.Text = "Por favor ingrese la factura para continuar"
            Me.Mensaje_Error.ForeColor = Drawing.Color.Red
            Exit Sub
        End If
        
        '8957 - CIM GORTIZ - 28/05/2014 - cambio parametro SRE por nuevo esquema de envio alerta en AXIS
        If lbl_est_mail_cliente.Text <> "S" Then
            Dim tipo_novedad As String = "SRSI"
            Dim destinatario As String = ""
            Dim telefono_administrador As String = ""
            Dim therowindex As Integer = 0
            Dim theid As String = ""
            tramite = CType(FormView1.FindControl("Literal18"), Literal).Text
            correo = CType(FormView1.FindControl("ltl_correo"), Literal).Text
        
            For Each row As GridViewRow In gv_lineas_solicitud.Rows()
                therowindex = row.RowIndex
                theid = DirectCast(gv_lineas_solicitud.Rows(therowindex).FindControl("lbl_num_rep_det"), Label).Text.ToString()
                destinatario = destinatario + " " + theid
            Next


            destinatario = destinatario.Trim()
            destinatario = destinatario.Replace(" ", "~")
        
            Try
                Dim tbl7 As New Data.DataTable
                Dim query7 As String
                query7 = "select medio, num_admin from tbl_bitacora_ws_solicitud_sim where id_sim = " & tramite
                Dim conn10 As System.Data.SqlClient.SqlConnection
                Dim conexion2 As conexiones = New conexiones
                Dim string_sql As String = Devuelve_cadena(1)
                
                conn10 = New System.Data.SqlClient.SqlConnection(string_sql)
                Dim cmd15 = New System.Data.SqlClient.SqlCommand(query7, conn10)
                cmd15.CommandType = Data.CommandType.Text
                conn10.Open()
                       
                Dim reader7 As System.Data.SqlClient.SqlDataReader = cmd15.ExecuteReader()
                If reader7.Read Then
                    consult = reader7.Item("medio").ToString
                    medio = consult
                    consult = reader7.Item("num_admin").ToString
                    telefono_administrador = consult
                End If
                reader7.Close()
                conn10.Close()
            Catch ex As Exception
            End Try
        
            observacion = correo & "~" & tramite & "~" & fecha & "~EXITO"
        
            Dim par1 As String = "<Parametros_Transaccion> " & _
                                 "  <parametros> " & _
                                 "    <pv_id_servicio>" & telefono_administrador & "</pv_id_servicio> " & _
                                 "    <pv_tipo_nov>" & tipo_novedad & "</pv_tipo_nov> " & _
                                 "    <pv_medio>" & medio & "</pv_medio> " & _
                                 "    <pv_observacion>" & observacion & "</pv_observacion> " & _
                                 "    <pv_destinatario>" & destinatario & "</pv_destinatario> " & _
                                 "  </parametros> " & _
                                 "</Parametros_Transaccion>"
            
            par1 = par1.Replace("*", "")
            Dim doc As XmlDocument = New XmlDocument()
            doc.LoadXml(par1)
            Dim root As XmlElement = doc.DocumentElement
            Dim Consulta As New conexiones
            Dim p As WebReference.sre = New WebReference.sre()
            Dim m2 As System.Xml.XmlElement = p.sreReceptaTransaccion(idInsta, IdtipoTran, Integ, CodAlterno, Us, Clav, sreDS, root)
            Dim nodelist As XmlNodeList = m2.ChildNodes.Item(2).ChildNodes
        
            Dim id_cod_error As String = ""


            For Each node As XmlNode In nodelist
                If node.Name.Equals("COD_RESPUESTA") Then
                    id_cod_error = node.InnerText
                End If
            Next
            
            If id_cod_error <> "0" Then
                Me.Mensaje_Error.Text = "Error al enviar mail al cliente."
                lbl_est_mail_cliente.Text = "N"
            Else
                Me.Mensaje_Error.Text = "Se envia mail al cliente y"
                lbl_est_mail_cliente.Text = "S"
            End If
        End If
        
        ' 8957 - CIM GORTIZ - Actualizacion del tramite sin validar el envio del mail.
        ds_actualiza.InsertParameters.Item("id").DefaultValue = CType(FormView1.FindControl("ltl_id_proc"), Literal).Text
        ds_actualiza.Insert()
        
        ds_actualiza.UpdateParameters.Item("id").DefaultValue = CType(FormView1.FindControl("ltl_id_proc"), Literal).Text
        ds_actualiza.Update()
        
        Me.Mensaje_Error.Text = Me.Mensaje_Error.Text.ToString + " Se actualiza el trámite"
        Me.Mensaje_Error.ForeColor = Drawing.Color.Red
        
        ds_con_workflow.DataBind()
        ds_consultar.DataBind()
        GridView1.DataBind()
        FormView1.DataBind()
    End Sub
    'FIN Proyecto [8957]
    
    Function Devuelve_cadena(ByVal codigo As Integer) As String
        Try
            Select Case codigo
                Case 1
                    Return ConfigurationManager.ConnectionStrings("Intr_callConnectionString").ConnectionString
                Case 2
                    Return ConfigurationManager.ConnectionStrings("Intr_callConnectionString").ConnectionString
                Case Else
                    Return ""
            End Select
        Catch ex As Exception
            Return ""
        End Try
    End Function
    
    
    Protected Sub Valida_Campo()
        Dim tramite As String = ""
        Dim consult As String = ""
        Dim estado_envio_mail As String = ""
        
        tramite = CType(FormView1.FindControl("Literal18"), Literal).Text
        Try
            Dim tbl As New Data.DataTable
            Dim query As String
            query = "SELECT [ultimo_estado], [est_mail_cliente] FROM [tbl_atv_reposicion_sim_proceso] WHERE ([id_padre] = '" & tramite & "'  )"
            Dim conn9 As System.Data.SqlClient.SqlConnection
            Dim conexion As conexiones = New conexiones
            Dim string_oracle As String = Devuelve_cadena(1)
                
            conn9 = New System.Data.SqlClient.SqlConnection(string_oracle)
            Dim cmd9 = New System.Data.SqlClient.SqlCommand(query, conn9)
            cmd9.CommandType = Data.CommandType.Text
            conn9.Open()
                
            Dim reader As System.Data.SqlClient.SqlDataReader = cmd9.ExecuteReader()


            If reader.Read Then
                consult = reader.Item("ultimo_estado").ToString()
                estado_envio_mail = reader.Item("est_mail_cliente").ToString()
                LLena_Campos()
                
                If consult = "A" Then
                    lbl_est_tramite.Text = "A"
                ElseIf consult = "R" Then
                    lbl_est_tramite.Text = "R"
					
                '[22735] - Reposicion SIMCARD corporativo
				ElseIf consult = "X" or consult = "C" Then
                    lbl_est_tramite.Text = consult
					pnl_soporte_empresarial.Enabled = False
					pnl_DetalleSolicitud.Enabled = False
					modifica.Visible = False
				'[22735] - Reposicion SIMCARD corporativo
				
				Else
                    lbl_est_tramite.Text = "E"
				End If
                '    LLena_Campos()
                '    txt_recibido.Enabled = False
                '    txt_factura.Enabled = False
                '    txt_guia.Enabled = False
                '    txt_fecha_i.Enabled = False
                '    ddl_hora_i.Enabled = False
                '    btn_guardar.Enabled = False
                'Else
                '    LLena_Campos()
                'End If
            End If
            reader.Close()
            
            If estado_envio_mail = "" Then
                estado_envio_mail = "N"
            End If
            
            lbl_est_mail_cliente.Text = estado_envio_mail
        Catch ex As Exception
        End Try
    End Sub
    
    
    Protected Sub LLena_Campos()
              
        Dim tramite As String = ""
        Dim consult As String = ""
        Dim consult1 As String = ""
        Dim consult2 As String = ""
        Dim consult3 As String = ""
        Dim consult4 As String = ""
        Dim consult5 As String = ""
       
        tramite = CType(FormView1.FindControl("Literal18"), Literal).Text
        Try
            Dim tbl As New Data.DataTable
            Dim query As String
            query = "SELECT [nom_recibe_simcard] FROM [tbl_bitacora_ws_solicitud_sim] WHERE ([id_sim] = '" & tramite & "'  )"
            Dim conn9 As System.Data.SqlClient.SqlConnection
            Dim conexion As conexiones = New conexiones
            Dim string_oracle As String = Devuelve_cadena(1)
                
            conn9 = New System.Data.SqlClient.SqlConnection(string_oracle)
            Dim cmd9 = New System.Data.SqlClient.SqlCommand(query, conn9)
            cmd9.CommandType = Data.CommandType.Text
            conn9.Open()
                
            Dim reader As System.Data.SqlClient.SqlDataReader = cmd9.ExecuteReader()


            If reader.Read Then
                consult = reader.Item("nom_recibe_simcard").ToString()
                txt_recibido.Text = consult
            End If
            reader.Close()
        Catch ex As Exception
              
        End Try
            
        'Llena Factura     
        Try
            Dim tbl1 As New Data.DataTable
            Dim query1 As String
            query1 = "SELECT [factura] FROM [tbl_atv_reposicion_sim_proceso] WHERE ([id_padre] = '" & tramite & "'  )"
            Dim conn9 As System.Data.SqlClient.SqlConnection
            Dim conexion As conexiones = New conexiones
            Dim string_oracle1 As String = Devuelve_cadena(1)
                
            conn9 = New System.Data.SqlClient.SqlConnection(string_oracle1)
            Dim cmd10 = New System.Data.SqlClient.SqlCommand(query1, conn9)
            cmd10.CommandType = Data.CommandType.Text
            conn9.Open()
                
            Dim reader1 As System.Data.SqlClient.SqlDataReader = cmd10.ExecuteReader()
            If reader1.Read Then
                consult1 = reader1.Item("factura").ToString()
                txt_factura.Text = consult1
            End If
            reader1.Close()
        Catch ex As Exception
        End Try
        
        'LLena Guia de Remision            
        Try
            Dim tbl2 As New Data.DataTable
            Dim query2 As String
            query2 = "SELECT [guia_remision] FROM [tbl_atv_reposicion_sim_proceso] WHERE ([id_padre] = '" & tramite & "'  )"
            Dim conn9 As System.Data.SqlClient.SqlConnection
            Dim conexion As conexiones = New conexiones
            Dim string_oracle1 As String = Devuelve_cadena(1)
                
            conn9 = New System.Data.SqlClient.SqlConnection(string_oracle1)
            Dim cmd11 = New System.Data.SqlClient.SqlCommand(query2, conn9)
            cmd11.CommandType = Data.CommandType.Text
            conn9.Open()
                
            Dim reader2 As System.Data.SqlClient.SqlDataReader = cmd11.ExecuteReader()
            If reader2.Read Then
                consult2 = reader2.Item("guia_remision").ToString()
                txt_guia.Text = consult2
            End If
            reader2.Close()
        Catch ex As Exception
        End Try
        
        '8957 - CIM GORTIZ - 10/06/2014 - Se setea la fecha de hoy cuando no tenga fecha de entrega
        consult3 = CType(FormView1.FindControl("Literal13"), Literal).Text
        
        If consult3 = "" Then
            txt_fecha_i.Text = Day(Now()) & "/" & Month(Now()) & "/" & Year(Now())
        Else
            txt_fecha_i.Text = consult3.Substring(0, 10)
        End If
        
        'LLena recibido_por         
        Try
            Dim tbl4 As New Data.DataTable
            Dim query4 As String
            query4 = "SELECT [recibido_por] FROM [tbl_atv_reposicion_sim_proceso] WHERE ([id_padre] = '" & tramite & "'  )"
            Dim conn9 As System.Data.SqlClient.SqlConnection
            Dim conexion As conexiones = New conexiones
            Dim string_oracle2 As String = Devuelve_cadena(1)
                
            conn9 = New System.Data.SqlClient.SqlConnection(string_oracle2)
            Dim cmd13 = New System.Data.SqlClient.SqlCommand(query4, conn9)
            cmd13.CommandType = Data.CommandType.Text
            conn9.Open()
                
            Dim reader4 As System.Data.SqlClient.SqlDataReader = cmd13.ExecuteReader()
            If reader4.Read Then
                consult4 = reader4.Item("recibido_por").ToString
                txt_recibido.Text = consult4
            End If
            reader4.Close()
        Catch ex As Exception
        End Try
        
        If consult4 = "" Then
            txt_recibido.Text = consult
        End If
        '8957 - CIMA GORTIZ - 10/06/2014 - Consulta de minutos de la fecha de entrega
        'Setear hora_entrega
        ddl_hora_i.SelectedValue = CType(FormView1.FindControl("Literal14"), Literal).Text
        'Setear minutos de entrega
        txt_min_entrega.Text = CType(FormView1.FindControl("Literal16"), Literal).Text
        If txt_min_entrega.Text = "" Then
            txt_min_entrega.Text = "00"
        End If
    End Sub
    
    '8957 - CIM GORTIZ - 06/06/2014 - Mejoras ingreso de simcard en detalle de lineas
    Protected Sub gv_lineas_solicitud_RowEditing(sender As Object, e As System.Web.UI.WebControls.GridViewEditEventArgs)
        gv_lineas_solicitud.EditIndex = e.NewEditIndex
    End Sub


    Protected Sub gv_lineas_solicitud_RowCancelingEdit(sender As Object, e As System.Web.UI.WebControls.GridViewCancelEditEventArgs)
        gv_lineas_solicitud.EditIndex = -1
        ds_con_det.DataBind()
    End Sub


    Protected Sub gv_lineas_solicitud_RowUpdating(sender As Object, e As System.Web.UI.WebControls.GridViewUpdateEventArgs)
        Dim txt_num_simcard_tmp As TextBox = DirectCast(gv_lineas_solicitud.Rows(e.RowIndex).FindControl("txt_num_simcard"), TextBox)
        Dim id_det_sim As Integer = gv_lineas_solicitud.DataKeys(e.RowIndex).Value
        ds_con_det.UpdateParameters.Item("num_sim").DefaultValue = txt_num_simcard_tmp.Text.ToString()
        ds_con_det.UpdateParameters.Item("id_sim_det").DefaultValue = id_det_sim.ToString()
        ds_con_det.Update()
        
        'Se actualiza las simcard's en la tabla 
        Dim conn As SqlConnection = New SqlConnection(ConfigurationManager.ConnectionStrings("intr_callConnectionString").ConnectionString)
        Dim cmd As SqlCommand = New SqlCommand()
        Dim campo_nombre As String = "simcard"
        Dim id_sim As String = CType(FormView1.FindControl("Literal18"), Literal).Text
        cmd.Connection = conn
        If e.RowIndex = 0 Then
            campo_nombre = "simcard"
        ElseIf e.RowIndex = 1 Then
            campo_nombre = "sim2"
        ElseIf e.RowIndex = 2 Then
            campo_nombre = "sim3"
        ElseIf e.RowIndex = 3 Then
            campo_nombre = "sim4"
        ElseIf e.RowIndex = 4 Then
            campo_nombre = "sim5"
        ElseIf e.RowIndex = 5 Then
            campo_nombre = "sim6"
        ElseIf e.RowIndex = 6 Then
            campo_nombre = "sim7"
        ElseIf e.RowIndex = 7 Then
            campo_nombre = "sim8"
        ElseIf e.RowIndex = 8 Then
            campo_nombre = "sim9"
        Else
            campo_nombre = "sim10"
        End If
        cmd.CommandText = "update Tbl_atv_reposicion_sim_proceso set " & campo_nombre & " = '" & txt_num_simcard_tmp.Text.ToString() & "' where id_padre = '" & id_sim & "'"
        Dim previousConnectionState As ConnectionState
        previousConnectionState = conn.State
        
        Try
            If conn.State = ConnectionState.Closed Then
                conn.Open()
            End If
            cmd.ExecuteNonQuery()
        Finally
            If previousConnectionState = ConnectionState.Closed Then
                conn.Close()
            End If
        End Try
    End Sub
    
    Protected Sub btn_guardar_detalle_Click(sender As Object, e As System.EventArgs)
        Dim txt_num_simcard_tmp As TextBox
        Dim therowindex As Integer = 0
        
        For Each row As GridViewRow In gv_lineas_solicitud.Rows()
            therowindex = row.RowIndex
            txt_num_simcard_tmp = DirectCast(gv_lineas_solicitud.Rows(therowindex).FindControl("txt_num_simcard"), TextBox)
            ds_con_det.UpdateParameters.Item("num_sim").DefaultValue = txt_num_simcard_tmp.Text.ToString()
            ds_con_det.UpdateParameters.Item("id_sim_det").DefaultValue = gv_lineas_solicitud.DataKeys(therowindex).Value
            ds_con_det.Update()
        Next
        
        ds_con_det.DataBind()
        gv_lineas_solicitud.DataBind()
    End Sub
    'FIN CIM GORTIZ - 20/06/2014 - Mejoras ingreso de simcard en detalle de lineas
</script>
<script runat="server">
    


</script>
<script language="javascript">




</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Reposici&#243;n de Simcard | Consulta Detalle</title>
    <script language="javascript" src="/portalsco/include/js/calendar/popcalendar.js"></script>
    <link href="/portalsco/include/js/calendar/popcalendar.css" type="text/css" rel="stylesheet">
    <style type="text/css">
        .style3
        {
            width: 251px;
            height: 25px;
        }
        .style4
        {
            width: 251px;
            height: 18px;
        }
        .style5
        {
            width: 164px;
            height: 25px;
        }
        .style6
        {
            width: 164px;
            height: 18px;
        }
        .style7
        {
            width: 164px;
        }
        .style8
        {
            background-image: url('../../../App_Themes/White/images/footer_repeat.gif');
            background-repeat: repeat-x;
            width: 800px;
            height: 20px;
            text-align: center;
            color: White;
            margin-bottom: -18px;
            margin-left: auto;
            margin-right: auto;
        }
        .style9
        {
            width: 251px;
        }
        .style10
        {
            width: 164px;
            height: 20px;
        }
        .style11
        {
            width: 251px;
            height: 20px;
        }
        .style12
        {
            width: 150px;
            height: 15px;
        }
        .style13
        {
            width: 230px;
            height: 15px;
        }
        .style14
        {
            width: 180px;
            height: 15px;
        }
    </style>
</head>
<body leftmargin="0" rightmargin="0" topmargin="0">
    <form id="form1" runat="server">
    <asp:HiddenField ID="sesion" runat="server" />
    <span style="color: #ff0000">
        <asp:HiddenField ID="ip" runat="server" />
    </span>
    <table bgcolor="#e90505" cellpadding="0" cellspacing="0" style="text-align: center;
        width: 936px;">
        <tr>
            <td background="../../../images/apl/simcard.jpg" bgcolor="#e90505" style="text-align: right;
                height: 89px;" width="550">
                <strong><em><span style="font-size: 10pt; color: #ffffff"><span style="font-size: 8pt">
                </span></span></em></strong>&nbsp;&nbsp;
            </td>
        </tr>
    </table>
    <br />
    <asp:FormView ID="FormView1" runat="server" DataSourceID="ds_consultar" Visible="False"
        DataKeyNames="id_sim" SkinID="porta" OnDataBound="FormView1_DataBound">
        <ItemTemplate>
            <table style="width: 710px" id="Table4">
                <tr>
                    <td class="red" style="width: 150px; height: 20px">
                        <span style="font-size: 9pt; color: #990000;">DATOS DEL CLIENTE</span>
                    </td>
                    <td style="width: 230px; height: 20px">
                        <span style="color: #ff0000"></span>
                    </td>
                    <td style="width: 150px; height: 20px">
                        <span style="font-size: 9pt; color: #ff0000"><strong>DATOS DEL TRÁMITE</strong></span>
                    </td>
                    <td style="width: 180px; height: 20px">
                    </td>
                </tr>
                <tr>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">No. Trámite:</span></strong>
                    </td>
                    <td style="width: 230px; height: 15px">
                        <asp:Literal ID="Literal18" runat="server" Text='<%# Eval("id_sim") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Fecha de Entrega:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal13" runat="server" Text='<%# Eval("fecha_entrega", "{0:d}") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Asesor Empresarial:</span></strong>
                    </td>
                    <td style="width: 230px; height: 15px">
                        <asp:Literal ID="Literal1" runat="server" Text='<%# Eval("nom_ases") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Hora de Entrega:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal14" runat="server" Text='<%# Eval("hora_entrega") %>'></asp:Literal>:<asp:Literal
                            ID="Literal16" runat="server" Text='<%# Eval("min_entrega") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Email del Asesor:</span></strong>
                    </td>
                    <td style="width: 230px; height: 15px">
                        <asp:Literal ID="Literal29" runat="server" Text='<%# Eval("mail") %>'></asp:Literal>
                    </td>
                    <%--INICIO CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
                    <%--<td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Simcard:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal15" runat="server" Text='<%# Eval("simcard") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Telf. de Reposicion:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal51" runat="server" Text='<%# Eval("telf_reposicion") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Motivo:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal31" runat="server" Text='<%# Eval("motivo") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Tipo Chip:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal41" runat="server" Text='<%# Eval("tipo_chip") %>'></asp:Literal>
                    </td>--%>
                    <%--FIN CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
                </tr>
                <tr>
                    <td style="width: 150px; height: 15px;">
                        <strong><span style="color: #000000">Nombre del Cliente:</span></strong>
                    </td>
                    <td style="width: 230px; height: 15px;">
                        <asp:Literal ID="Literal2" runat="server" Text='<%# Eval("nom_cliente") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px;">
                        <strong><span style="color: #000000">Provincia envío:</span></strong>
                    </td>
                    <td style="width: 230px; height: 15px;">
                        <asp:Literal ID="ltl_provincia" runat="server" Text='<%# Eval("provincia") %>'></asp:Literal>
                    </td>
                    <%--INICIO CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
                    <%--<td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Simcard 2:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal20" runat="server" Text='<%# Eval("sim2") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Telf. de Reposicion 2:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal52" runat="server" Text='<%# Eval("telf_reposicion_2") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Motivo 2:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal32" runat="server" Text='<%# Eval("motivo2") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Tipo Chip 2:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal42" runat="server" Text='<%# Eval("tipo_chip2") %>'></asp:Literal>
                    </td>--%>
                    <%--FIN CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
                </tr>
                <tr>
                    <td style="width: 150px; height: 15px;">
                        <strong><span style="color: #000000">Cuenta Axis:</span></strong>
                    </td>
                    <td style="width: 230px; height: 15px;">
                        <asp:Literal ID="Literal3" runat="server" Text='<%# Eval("cta_axis") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px;">
                        <strong><span style="color: #000000">Ciudad envío:</span></strong>
                    </td>
                    <td style="width: 230px; height: 15px;">
                        <asp:Literal ID="ltl_ciudad" runat="server" Text='<%# Eval("ciudad") %>'></asp:Literal>
                    </td>
                    <%--INICIO CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
                    <%--<td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Simcard 3:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal21" runat="server" Text='<%# Eval("sim3") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Telf. de Reposicion 3:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal53" runat="server" Text='<%# Eval("telf_reposicion_3") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Motivo 3:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal33" runat="server" Text='<%# Eval("motivo3") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Tipo Chip 3:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal43" runat="server" Text='<%# Eval("tipo_chip3") %>'></asp:Literal>
                    </td>--%>
                    <%--FIN CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
                </tr>
                <tr>
                    <td style="width: 150px; height: 15px;">
                        <strong><span style="color: #000000">Dirección:</span></strong>
                    </td>
                    <td style="width: 230px; height: 15px;">
                        <asp:Literal ID="Literal4" runat="server" Text='<%# eval("direccion") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px;">
                        <strong><span style="color: #000000">Referencia de envío:</span></strong>
                    </td>
                    <td style="width: 230px; height: 15px;">
                        <asp:Literal ID="ltl_ref_direccion" runat="server" Text='<%# eval("refer_direc") %>'></asp:Literal>
                    </td>
                    <%--INICIO CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
                    <%--<td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Simcard 4:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal22" runat="server" Text='<%# Eval("sim4") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Telf. de Reposicion 4:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal54" runat="server" Text='<%# Eval("telf_reposicion_4") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Motivo 4:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal34" runat="server" Text='<%# Eval("motivo4") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Tipo Chip 4:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal44" runat="server" Text='<%# Eval("tipo_chip4") %>'></asp:Literal>
                    </td>--%>
                    <%--FIN CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
                </tr>
                <tr>
                    <td class="style12">
                        <strong><span style="color: #000000">Contacto:</span></strong>
                    </td>
                    <td class="style13">
                        <asp:Literal ID="Literal5" runat="server" Text='<%# Eval("nom_contacto") %>'></asp:Literal>
                    </td>
                    <%--INICIO CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
                    <%--<td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Simcard 5:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal23" runat="server" Text='<%# Eval("sim5") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Telf. de Reposicion 5:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal55" runat="server" Text='<%# Eval("telf_reposicion_5") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Motivo 5:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal35" runat="server" Text='<%# Eval("motivo5") %>'></asp:Literal>
                    </td>--%>
                    <td class="style12">
                        <strong><span style="color: #000000">Correo Cliente:</span></strong>
                    </td>
                    <td class="style14">
                        <asp:Literal ID="ltl_correo" runat="server" Text='<%# Eval("correo_cliente") %>'></asp:Literal>
                    </td>
                    <%--FIN CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
                </tr>
                <tr>
                    <td style="width: 150px">
                        <strong><span style="color: #000000">Telf. de Contacto 1:</span></strong>
                    </td>
                    <td style="width: 230px">
                        <asp:Literal ID="ltl_telf_cont_1" runat="server" Text='<%# Eval("telf_contacto") %>'></asp:Literal>
                    </td>
                    <%--INICIO CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
                    <%--<td style="width: 150px">
                        <strong><span style="color: #000000">Simcard 6:</span></strong>
                    </td>
                    <td style="width: 180px">
                        <asp:Literal ID="Literal24" runat="server" Text='<%# Eval("sim6") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Telf. de Reposicion 6:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal56" runat="server" Text='<%# Eval("telf_reposicion_6") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px">
                        <strong><span style="color: #000000">Motivo 6:</span></strong>
                    </td>
                    <td style="width: 180px">
                        <asp:Literal ID="Literal36" runat="server" Text='<%# Eval("motivo6") %>'></asp:Literal>
                    </td>--%>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Estado envío correo al cliente:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="ltl_est_mail" runat="server" Text='<%# Eval("est_mail") %>'></asp:Literal>
                    </td>
                    <%--FIN CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
                </tr>
                <tr>
                    <td style="width: 150px">
                        <strong><span style="color: #000000">Telf. de Contacto 2:</span></strong>
                    </td>
                    <td style="width: 230px">
                        <asp:Literal ID="ltl_telf_cont_2" runat="server" Text='<%# Eval("telf_contacto2") %>'></asp:Literal>
                    </td>
                    <%--INICIO CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
                    <%--<td style="width: 150px">
                        <strong><span style="color: #000000">Simcard 7:</span></strong>
                    </td>
                    <td style="width: 180px">
                        <asp:Literal ID="Literal25" runat="server" Text='<%# Eval("sim7") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Telf. de Reposicion 7:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal57" runat="server" Text='<%# Eval("telf_reposicion_7") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px">
                        <strong><span style="color: #000000">Motivo 7:</span></strong>
                    </td>
                    <td style="width: 180px">
                        <asp:Literal ID="Literal37" runat="server" Text='<%# Eval("motivo7") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Tipo Chip 7:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal47" runat="server" Text='<%# Eval("tipo_chip7") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td style="width: 150px">
                        <strong><span style="color: #000000">Número de Reposición:</span></strong>
                    </td>
                    <td style="width: 230px">
                        <asp:Literal ID="Literal7" runat="server" Text='<%# Eval("num_repo") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px">
                        <strong><span style="color: #000000">Simcard 8:</span></strong>
                    </td>
                    <td style="width: 180px">
                        <asp:Literal ID="Literal26" runat="server" Text='<%# Eval("sim8") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Telf. de Reposicion 8:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal58" runat="server" Text='<%# Eval("telf_reposicion_8") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px">
                        <strong><span style="color: #000000">Motivo 8:</span></strong>
                    </td>
                    <td style="width: 180px">
                        <asp:Literal ID="Literal38" runat="server" Text='<%# Eval("motivo8") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Tipo Chip 8:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal48" runat="server" Text='<%# Eval("tipo_chip8") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td style="width: 150px">
                        <strong><span style="color: #000000">Adicionales Reposición:</span></strong>
                    </td>
                    <td style="width: 230px">
                        <asp:Literal ID="Literal17" runat="server" Text='<%# Eval("num_repo_v") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px">
                        <strong><span style="color: #000000">Simcard 9:</span></strong>
                    </td>
                    <td style="width: 180px">
                        <asp:Literal ID="Literal27" runat="server" Text='<%# Eval("sim9") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Telf. de Reposicion 9:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal59" runat="server" Text='<%# Eval("telf_reposicion_9") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px">
                        <strong><span style="color: #000000">Motivo 9:</span></strong>
                    </td>
                    <td style="width: 180px">
                        <asp:Literal ID="Literal39" runat="server" Text='<%# Eval("motivo9") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Tipo Chip 9:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal49" runat="server" Text='<%# Eval("tipo_chip9") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>--%>
                    <td style="width: 150px">
                        <strong><span style="color: #000000">Tipo Cliente:</span></strong>
                    </td>
                    <td style="width: 230px">
                        <asp:Literal ID="ltl_tipo_cliente" runat="server" Text='<%# Eval("tipo") %>'></asp:Literal>
                    </td>
                    <%--<td style="width: 150px">
                        <strong><span style="color: #000000">Simcard 10:</span></strong>
                    </td>
                    <td style="width: 180px">
                        <asp:Literal ID="Literal28" runat="server" Text='<%# Eval("sim10") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Telf. de Reposicion 10:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal60" runat="server" Text='<%# Eval("telf_reposicion_10") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px">
                        <strong><span style="color: #000000">Motivo 10:</span></strong>
                    </td>
                    <td style="width: 180px">
                        <asp:Literal ID="Literal40" runat="server" Text='<%# Eval("motivo10") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Tipo Chip 10:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal50" runat="server" Text='<%# Eval("tipo_chip10") %>'></asp:Literal>
                    </td>--%>
                    <%--FIN CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
                </tr>
                <tr>
                    <td style="width: 150px; height: 20px">
                    </td>
                    <td style="width: 230px; height: 20px">
                    </td>
                    <td style="width: 150px; height: 20px">
                    </td>
                    <td style="width: 180px; height: 20px">
                        <asp:Literal ID="ltl_id_proc" runat="server" 
                            Text='<%# Eval("id_proc") %>' Visible="False"></asp:Literal>
                    </td>
                </tr>
            </table>
            <table style="width: 700px" id="Table5">
                <tr>
                    <td class="red" style="width: 250px; height: 15px">
                        <span style="font-size: 9pt; color: #990000;">ETAPAS DEL REQUERIMIENTO</span>
                    </td>
                    <td style="width: 515px; height: 15px">
                    </td>
                </tr>
            </table>
        </ItemTemplate>
        <EditItemTemplate>
            <table>
                <tr>
                    <td class="red" style="width: 190px; height: 25px">
                        ATENCIÓN ASES | EDICIÓN<br />
                    </td>
                </tr>
            </table>
            <table style="width: 440px" id="Table2">
                <tr>
                    <td class="red" style="width: 150px; height: 15px">
                        DATOS DEL CLIENTE
                    </td>
                    <td style="width: 290px; height: 15px">
                    </td>
                </tr>
                <tr>
                    <td class="atvblack" style="width: 150px; height: 15px">
                        Fecha
                    </td>
                    <td style="width: 290px; height: 15px">
                        <asp:Literal ID="Literal1" runat="server" Text='<%# eval("fecha_inicio") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td class="atvblack" style="width: 150px; height: 15px;">
                        Nombre del Cliente:
                    </td>
                    <td style="width: 290px; height: 15px;">
                        <asp:Literal ID="Literal2" runat="server" Text='<%# eval("nom_cliente") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td class="atvblack" style="width: 150px; height: 17px;">
                        No. de Cuenta:
                    </td>
                    <td style="width: 290px; height: 17px;">
                        <asp:Literal ID="Literal3" runat="server" Text='<%# eval("cta_axis") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td class="atvblack" style="width: 150px">
                        Celular:
                    </td>
                    <td style="width: 290px">
                        <asp:Literal ID="Literal4" runat="server" Text='<%# eval("numero") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td class="atvblack" style="width: 150px; height: 15px;">
                        RUC / Cédula:
                    </td>
                    <td style="width: 290px; height: 15px;">
                        <asp:Literal ID="Literal5" runat="server" Text='<%# eval("ruc") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td class="atvblack" style="width: 150px">
                        Tipo de Cuenta:
                    </td>
                    <td style="width: 290px">
                        <asp:Literal ID="Literal6" runat="server" Text='<%# eval("tipo_cta") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td class="atvblack" style="width: 150px">
                        Número(s) de la cta que solicita servicio:
                    </td>
                    <td style="width: 290px">
                        <asp:Literal ID="Literal7" runat="server" Text='<%# eval("numeros_cta") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td style="width: 150px; height: 20px;">
                    </td>
                    <td style="width: 290px; height: 20px;">
                    </td>
                </tr>
                <tr>
                    <td class="red" style="width: 150px">
                        DATOS DEL TRÁMITE
                    </td>
                    <td style="width: 290px">
                    </td>
                </tr>
                <tr>
                    <td class="atvblack" style="width: 150px">
                        Tipo de Trámite:
                    </td>
                    <td style="width: 290px">
                        <asp:Literal ID="Literal8" runat="server" Text='<%# eval("det_tram") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td class="atvblack" style="width: 150px; height: 15px">
                        Tipología:
                    </td>
                    <td style="width: 290px; height: 15px">
                        <asp:Literal ID="Literal11" runat="server" Text='<%# eval("tp") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td class="atvblack" style="width: 150px; height: 15px">
                        Estado Actual:
                    </td>
                    <td style="width: 290px; height: 15px">
                        <asp:Literal ID="Literal9" runat="server" Text='<%# eval("est") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td class="atvblack" style="width: 150px; height: 15px">
                        Login:
                    </td>
                    <td style="width: 290px; height: 15px">
                        <asp:Literal ID="Literal12" runat="server" Text='<%# eval("usuario") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td class="atvblack" style="width: 150px; height: 15px">
                        Observaciones:
                    </td>
                    <td style="width: 290px; height: 15px">
                        <asp:Literal ID="Literal10" runat="server" Text='<%# eval("observacion") %>'></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td style="width: 150px; height: 15px">
                    </td>
                    <td style="width: 290px; height: 15px">
                    </td>
                </tr>
                <tr>
                    <td class="atvblack" style="width: 150px; height: 15px">
                        Respuesta:
                    </td>
                    <td style="width: 290px; height: 15px">
                        <asp:TextBox ID="TextBox1" runat="server" Columns="45" MaxLength="300" Rows="7" TextMode="MultiLine"
                            Text='<%# bind("observacion") %>' Width="290px"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td class="atvblack" style="width: 150px; height: 15px">
                        Estado:
                    </td>
                    <td style="width: 290px; height: 15px">
                        <asp:DropDownList ID="DropDownList1" runat="server" DataSourceID="ds_estado" DataTextField="tp_nombre"
                            DataValueField="tp_codigo" SelectedValue='<%# bind("tipo") %>'>
                        </asp:DropDownList>
                        <asp:SqlDataSource ID="ds_estado" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
                            SelectCommand="select tp_nombre,tp_codigo from Tbl_adm_tipos where (pa_codigo=31)">
                        </asp:SqlDataSource>
                    </td>
                </tr>
            </table>
            <br />
            <asp:Button ID="act" runat="server" CommandName="Update" Text="Actualizar" />
        </EditItemTemplate>
    </asp:FormView>
    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataSourceID="ds_con_workflow"
        SkinID="porta" DataKeyNames="id_sim" Width="690px" Visible="False" AllowPaging="True"
        PageSize="5">
        <Columns>
            <asp:BoundField DataField="fecha" HeaderText="Fecha y Hora" SortExpression="fecha">
                <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
            </asp:BoundField>
            <asp:BoundField DataField="respuesta" HeaderText="Observaci&#243;n" SortExpression="respuesta">
                <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
            </asp:BoundField>
            <asp:BoundField DataField="login" HeaderText="Login" SortExpression="login">
                <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
            </asp:BoundField>
            <asp:BoundField DataField="est" HeaderText="Estado" SortExpression="est">
                <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
            </asp:BoundField>
        </Columns>
    </asp:GridView>
    <br />
    <%--INICIO CIM GORTIZ - 28/05/2014 - Mejoras presentacion detalle de lineas--%>
    <asp:Panel ID="pnl_DetalleSolicitud" runat="server" Style="text-align: left" Width="690px">
        <table align="center" border="0" style="border: thin ridge #FF0000; width: 10%;">
            <tr>
                <td align="left" class="style8" 
                    style="font-family: Calibri; font-style: normal; font-weight: bold; font-size: xx-small;">
                    Detalle de la solicitud
                </td>
            </tr>
            <tr align="center">
                <td align="left" bgcolor="White" class="style10">
                    <asp:GridView ID="gv_lineas_solicitud" runat="server" AutoGenerateColumns="False"
                        DataKeyNames="id_sim_det" DataSourceID="ds_con_det" EnableModelValidation="True"
                        OnRowCancelingEdit="gv_lineas_solicitud_RowCancelingEdit" OnRowEditing="gv_lineas_solicitud_RowEditing"
                        OnRowUpdating="gv_lineas_solicitud_RowUpdating" SkinID="porta" Style="text-align: center"
                        Width="100%">
                        <EmptyDataTemplate>
                            No hay lineas ingresadas
                        </EmptyDataTemplate>
                        <Columns>
                            <asp:TemplateField HeaderText="Número" SortExpression="num_rep_det">
                                <ItemTemplate>
                                    <asp:Label ID="lbl_num_rep_det" runat="server" Text='<%# Bind("telefono_Reposicion") %>'></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                                <EditItemTemplate>
                                    <asp:Label ID="lbl_num_rep_det_E" runat="server" Text='<%# Bind("telefono_Reposicion") %>'></asp:Label>
                                </EditItemTemplate>
                                <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Simcard" SortExpression="simcard_Reposicion">
                                <EditItemTemplate>
                                    <asp:TextBox ID="txt_num_simcard" runat="server" Text='<%# Bind("simcard_Reposicion") %>'></asp:TextBox>
                                </EditItemTemplate>
                                <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                                <ItemTemplate>
                                    <asp:TextBox ID="txt_num_simcard" runat="server" Text='<%# Bind("simcard_Reposicion") %>'></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Motivo" SortExpression="mot_rep_det">
                                <ItemTemplate>
                                    <asp:Label ID="lbl_mot_rep_det" runat="server" Text='<%# Bind("motivo_Reposicion") %>'></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                                <EditItemTemplate>
                                    <asp:Label ID="lbl_mot_rep_det_E" runat="server" Text='<%# Bind("motivo_Reposicion") %>'></asp:Label>
                                </EditItemTemplate>
                                <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Tipo Simcard" SortExpression="tip_rep_det">
                                <ItemTemplate>
                                    <asp:Label ID="lbl_tip_rep_det" runat="server" Text='<%# Bind("tipochip_Reposicion") %>'></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                                <EditItemTemplate>
                                    <asp:Label ID="lbl_tip_rep_det_E" runat="server" Text='<%# Bind("tipochip_Reposicion") %>'></asp:Label>
                                </EditItemTemplate>
                                <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle"
                                    Wrap="True" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Fecha Registro" SortExpression="fecha_reg" Visible="False">
                                <ItemTemplate>
                                    <asp:Label ID="lbl_fecha_registro_det" runat="server" Text='<%# Bind("fecha_registro") %>'></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                                <EditItemTemplate>
                                    <asp:Label ID="lbl_fecha_registro_det_E" runat="server" Text='<%# Bind("fecha_registro") %>'></asp:Label>
                                </EditItemTemplate>
                                <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Editar" Visible="False">
                                <ItemTemplate>
                                    <asp:ImageButton ID="btn_Edit_Rep" runat="server" CommandName="Edit" CssClass="btn-s"
                                        ImageUrl="~/images/adm/icon-edit.gif" />
                                </ItemTemplate>
                                <EditItemTemplate>
                                    <asp:ImageButton ID="btn_CancelEdit_Rep" runat="server" CommandName="Cancel" CssClass="btn-s"
                                        ImageUrl="~/images/adm/icon-cancel.gif" />
                                    &nbsp;<asp:ImageButton ID="btn_ActEdit_Rep" runat="server" CommandName="Update" CssClass="btn-s"
                                        ImageUrl="~/images/adm/icon-save.gif" ValidationGroup="DetRep_E" />
                                </EditItemTemplate>
                                <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                            </asp:TemplateField>
                        </Columns>
                        <RowStyle Wrap="False" />
                    </asp:GridView>
                </td>
            </tr>
            <tr>
                <td align="center">
                    <asp:Button ID="btn_guardar_detalle" runat="server" Height="18px" Text="Guardar"
                        Width="63px" Font-Bold="True" OnClick="btn_guardar_detalle_Click" />
                </td>
            </tr>
        </table>
        <br />
    </asp:Panel>
    <%--<td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Simcard:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal15" runat="server" Text='<%# Eval("simcard") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Telf. de Reposicion:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal51" runat="server" Text='<%# Eval("telf_reposicion") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Motivo:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal31" runat="server" Text='<%# Eval("motivo") %>'></asp:Literal>
                    </td>
                    <td style="width: 150px; height: 15px">
                        <strong><span style="color: #000000">Tipo Chip:</span></strong>
                    </td>
                    <td style="width: 180px; height: 15px">
                        <asp:Literal ID="Literal41" runat="server" Text='<%# Eval("tipo_chip") %>'></asp:Literal>
                    </td>--%>
    <asp:Panel ID="pnl_soporte_empresarial" runat="server" Enabled="False" Width="690px">
        <br />
        <table border="0" style="border: thin ridge #FF0000; width: 33%;" align="center">
            <tr>
                <td class="style8" colspan="2" 
                    style="font-family: Calibri; font-size: xx-small; font-weight: bold;">
                    Soporte Empresarial
                </td>
            </tr>
            <tr>
                <td class="style5">
                    <asp:Label ID="lbl_FechaEntrega" runat="server" Text="Fecha de Entrega:" Font-Bold="True"></asp:Label>
                </td>
                <td class="style3">
                    <asp:TextBox ID="txt_fecha_i" runat="server" Height="18px" Width="96px" onKeypress="if ((event.keyCode > 0 && event.keyCode < 47)|| (event.keyCode > 57 && event.keyCode < 256) ) event.returnValue = false;">           
                    </asp:TextBox>
                    <img id="imgFi" alt="calendar" height="17" name="imgFi" onclick="popUpCalendar(this,txt_fecha_i, 'dd/mm/yyyy');"
                        src="../../../images/apl/calendario.gif" style="cursor: hand" width="22" align="absMiddle" />
                </td>
            </tr>
            <tr>
                <td class="style6">
                    <asp:Label ID="lbl_hora" runat="server" Text="Hora de Entrega:" Font-Bold="True"></asp:Label>
                </td>
                <td class="style4">
                    <asp:DropDownList ID="ddl_hora_i" runat="server" Font-Bold="False" Font-Size="8pt">
                        <asp:ListItem>00</asp:ListItem>
                        <asp:ListItem>01</asp:ListItem>
                        <asp:ListItem>02</asp:ListItem>
                        <asp:ListItem>03</asp:ListItem>
                        <asp:ListItem>04</asp:ListItem>
                        <asp:ListItem>05</asp:ListItem>
                        <asp:ListItem>06</asp:ListItem>
                        <asp:ListItem>07</asp:ListItem>
                        <asp:ListItem>08</asp:ListItem>
                        <asp:ListItem>09</asp:ListItem>
                        <asp:ListItem>10</asp:ListItem>
                        <asp:ListItem>11</asp:ListItem>
                        <asp:ListItem>12</asp:ListItem>
                        <asp:ListItem>13</asp:ListItem>
                        <asp:ListItem>14</asp:ListItem>
                        <asp:ListItem>15</asp:ListItem>
                        <asp:ListItem>16</asp:ListItem>
                        <asp:ListItem>17</asp:ListItem>
                        <asp:ListItem>18</asp:ListItem>
                        <asp:ListItem>19</asp:ListItem>
                        <asp:ListItem>20</asp:ListItem>
                        <asp:ListItem>21</asp:ListItem>
                        <asp:ListItem>22</asp:ListItem>
                        <asp:ListItem>23</asp:ListItem>
                    </asp:DropDownList>
                    <asp:Label ID="Label5" runat="server" BorderStyle="None" Font-Bold="True" Font-Size="8pt"
                        Height="16px" Text=":"></asp:Label>
                    <asp:TextBox ID="txt_min_entrega" runat="server" Height="19px" MaxLength="2" onKeypress="if ((event.keyCode &gt; 0 &amp;&amp; event.keyCode &lt; 47)|| (event.keyCode &gt; 57 &amp;&amp; event.keyCode &lt; 256) ) event.returnValue = false;"
                        Width="36px">00</asp:TextBox>
                </td>
            </tr>
            <tr>
                <td class="style7">
                    <asp:Label ID="lbl_factura" runat="server" Text="Factura:" Font-Bold="True"></asp:Label>
                </td>
                <td class="style9">
                    <asp:TextBox ID="txt_factura" runat="server" Height="19px" Width="125px" 
                        onKeypress="if ((event.keyCode > 0 && event.keyCode < 47)|| (event.keyCode > 57 && event.keyCode < 256) ) event.returnValue = false;" 
                        MaxLength="9"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td class="style7">
                    <asp:Label ID="lbl_GuiaRemision" runat="server" Text="Guia de Remision:" Font-Bold="True"></asp:Label>
                </td>
                <td class="style9">
                    <asp:TextBox ID="txt_guia" runat="server" Height="18px" Width="125px" 
                        MaxLength="50"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td class="style10">
                    <asp:Label ID="lbl_recibido" runat="server" Text="Recibido Por:" Font-Bold="True"></asp:Label>
                </td>
                <td class="style11">
                    <asp:TextBox ID="txt_recibido" runat="server" Height="16px" Width="200px" 
                        MaxLength="100"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td class="style10">
                    <asp:Label ID="lbl_observacion" runat="server" Text="Observación:" Font-Bold="True"></asp:Label>
                </td>
                <td class="style11">
                    <asp:TextBox ID="txt_obs_act_tramite" runat="server" Height="17px" 
                        Width="250px" MaxLength="500"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td align="center" colspan="2">
                    <asp:TextBox ID="Mensaje_Error" runat="server" BorderColor="White" BorderStyle="None"
                        EnableTheming="False" Font-Italic="True" Height="25px" ReadOnly="True" Width="340px"></asp:TextBox>
                    <br />
                    <asp:Button ID="btn_guardar" runat="server" Height="18px" OnClick="btn_guardar_Click"
                        Text="Guardar" Width="63px" Font-Bold="True" />
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td class="style9">
                    <asp:Label ID="lbl_est_tramite" runat="server" Text="Estado_tramite" Visible="False"></asp:Label>
                    <asp:Label ID="lbl_est_mail_cliente" runat="server" Text="Estado_mail_cliente" Visible="False"></asp:Label>
                </td>
            </tr>
        </table>
    </asp:Panel>
    &nbsp;<br />
    <asp:HyperLink ID="modifica" Visible="True" runat="server">Modificar Trámite</asp:HyperLink><br />
    <asp:SqlDataSource ID="ds_con_workflow" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
        SelectCommand="atv_reposicion_flujo" SelectCommandType="StoredProcedure">
        <SelectParameters>
            <asp:QueryStringParameter Name="id_sim" QueryStringField="id_sim" />
            <asp:Parameter Direction="ReturnValue" Name="RETURN_VALUE" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="ds_consultar" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
        SelectCommand="atv_reposicion_detalle" UpdateCommand="atv_ases_workflow_actualizar"
        UpdateCommandType="StoredProcedure" SelectCommandType="StoredProcedure">
        <UpdateParameters>
            <asp:QueryStringParameter Name="id" QueryStringField="id" Type="Int32" />
            <asp:Parameter Name="observacion" Type="String" />
            <asp:Parameter Name="usuario" Type="String" />
            <asp:Parameter Name="tipo" Type="Int32" />
        </UpdateParameters>
        <SelectParameters>
            <asp:QueryStringParameter Name="id_sim" QueryStringField="id_sim" />
            <asp:Parameter Direction="ReturnValue" Name="RETURN_VALUE" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="ds_consulta_recibido" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
        SelectCommand="SELECT [nom_recibe_simcard] FROM [tbl_bitacora_ws_solicitud_sim] WHERE ([id_sim] = @id_sim)">
        <SelectParameters>
            <asp:Parameter Name="id_sim" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="ds_actualiza" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
        UpdateCommand="update tbl_atv_reposicion_sim_proceso set ultima_obs=@respuesta, ultima_fecha=GETDATE(), ultimo_login=@login, ultimo_estado=@est_tramite, fecha_entrega=cast(@fecha_entrega +' 00:00:00' as datetime), hora_entrega=@hora_i, min_entrega=@min_i, factura=@factura,guia_remision=@guia, recibido_por=@recibido, usuario_asistente=@sesion, est_mail_cliente=@estado_mail where id_proc=@id"
        
        InsertCommand="insert into  tbl_atv_reposicion_sim_etapa (id_padre, fecha, login, estado, respuesta, ip) values (@id, GETDATE(), @login, @estado, @respuesta, @ip)">
        <InsertParameters>
            <asp:Parameter Name="id" />
            <asp:SessionParameter Name="login" SessionField="USER" />
            <asp:ControlParameter ControlID="lbl_est_tramite" Name="estado" PropertyName="Text" />
            <asp:ControlParameter ControlID="txt_obs_act_tramite" Name="respuesta" 
                PropertyName="Text" />
            <asp:ControlParameter ControlID="ip" Name="ip" PropertyName="Value" />
        </InsertParameters>
        <UpdateParameters>
            <asp:SessionParameter Name="sesion" SessionField="USER" Type="String" />
            <asp:ControlParameter Name="fecha_entrega" ControlID="txt_fecha_i" PropertyName="Text"
                Type="DateTime" />
            <asp:ControlParameter Name="hora_i" ControlID="ddl_hora_i" PropertyName="SelectedValue"
                DefaultValue="-1" />
            <asp:ControlParameter Name="factura" ControlID="txt_factura" PropertyName="Text"
                Type="String" />
            <asp:ControlParameter Name="guia" ControlID="txt_guia" PropertyName="Text" Type="String" />
            <asp:ControlParameter Name="recibido" ControlID="txt_recibido" PropertyName="Text"
                Type="String" />
            <asp:ControlParameter ControlID="lbl_est_tramite" Name="est_tramite" PropertyName="Text"
                DefaultValue="" />
            <asp:ControlParameter ControlID="txt_min_entrega" Name="min_i" PropertyName="Text"
                DefaultValue="00" />
            <asp:ControlParameter ControlID="lbl_est_mail_cliente" Name="estado_mail" PropertyName="Text" />
            <asp:SessionParameter Name="login" SessionField="USER" />
            <asp:ControlParameter ControlID="txt_obs_act_tramite" Name="respuesta" 
                PropertyName="Text" />
            <asp:Parameter Name="id" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <span style="color: #ff0000">
        <asp:SqlDataSource ID="ds_con_det" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
            SelectCommand="SELECT id_sim_det, telefono_Reposicion, simcard_Reposicion, CASE motivo_Reposicion WHEN 'R' THEN 'Robo' WHEN 'A' THEN 'Daño/Perdida' WHEN 'S' THEN 'Stock de simcard' WHEN 'L' THEN 'En Linea' ELSE motivo_Reposicion END AS motivo_Reposicion, CASE tipochip_Reposicion WHEN 'C' THEN 'Simcard Normal' WHEN 'M' THEN 'Mini Simcard' WHEN 'I' THEN 'Micro Simcard' WHEN 'N' THEN 'Nano Simcard' ELSE tipochip_Reposicion END AS tipochip_Reposicion, fecha_Registro FROM Tbl_atv_reposicion_sim_detalle WHERE (id_sim = @id_sim) AND (estado = 'F') ORDER BY id_sim_det"
            CancelSelectOnNullParameter="False" InsertCommand="INSERT INTO Tbl_atv_reposicion_sim_detalle(id_CuentaAxis, telefono_Reposicion, motivo_Reposicion, tipochip_Reposicion, fecha_Registro, usuario_Registro, estado) VALUES (@id_CuentaAxis, @telefono_repsim, @motivo_repsim, @tipochp_repsim, getdate(), @usuario_Registro, 'P')"
            UpdateCommand="UPDATE Tbl_atv_reposicion_sim_detalle SET simcard_Reposicion= @num_sim WHERE (id_sim_det = @id_sim_det)">
            <InsertParameters>
                <asp:ControlParameter ControlID="cta_axis" Name="id_CuentaAxis" PropertyName="Text" />
                <asp:ControlParameter ControlID="txt_Det_NumRep" Name="telefono_repsim" PropertyName="Text" />
                <asp:ControlParameter ControlID="ddl_Det_MotRep" Name="motivo_repsim" PropertyName="SelectedValue" />
                <asp:ControlParameter ControlID="ddl_Det_TipChip" Name="tipochp_repsim" PropertyName="SelectedValue" />
                <asp:Parameter Name="usuario_Registro" />
            </InsertParameters>
            <SelectParameters>
                <asp:QueryStringParameter Name="id_sim" QueryStringField="id_sim" />
            </SelectParameters>
            <UpdateParameters>
                <asp:Parameter Name="id_sim_det" />
                <asp:Parameter Name="num_sim" />
            </UpdateParameters>
        </asp:SqlDataSource>
    </span>
    <br />
    <asp:Label ID="permiso" runat="server" Text="Usted no es usuario autorizado para el acceso a este aplicativo, comuniquese con su supervisor o el Administrador del Portal SCO."></asp:Label>
    <br />
    <br />
    </form>
</body>
</html>
