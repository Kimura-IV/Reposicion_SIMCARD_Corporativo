<%--
***************************************************************************************************************
DESCRIPCION: Formulario de ingreso de solicitud de reposicion Simcard
MODIFICADO POR: Cima Galo Ortiz C. 
MOTIVO DE MODIFICACIÓN: Se realizan las siguientes mejoras
                        = Ingreso de telefono, tipo de simcard y motivo para la reposición desde
                          un nuevo panel en este formulario
                        = Ingresar datos como la ciudad, región y número administrador de la cuenta
                        = Ingresar correo del cliente al que se le enviará una alerta mail una vez
                          que su tramite tenga fecha de entrega.
FECHA DE MODIFICACIÓN: 24/06/2014
***************************************************************************************************************
***************************************************************************************************************
DESCRIPCION: Formulario de ingreso de solicitud de reposicion Simcard
MODIFICADO POR: Cima Galo Ortiz C. 
MOTIVO DE MODIFICACIÓN: Mejora en la presentacion del panel de detalle de la solicitud
FECHA DE MODIFICACIÓN: 30/06/2014
***************************************************************************************************************
***************************************************************************************************************
DESCRIPCION: Formulario de ingreso de solicitud de reposicion Simcard
MODIFICADO POR: Cima Galo Ortiz C. 
MOTIVO DE MODIFICACIÓN: Se elimina opcion para registrar en la BD tipos de simcard MICRO SIMCARD
FECHA DE MODIFICACIÓN: 02/07/2014-2
***************************************************************************************************************
--%>

<%@ page language="VB" stylesheettheme="white" debug="true" %>

<%@ register src="menu.ascx" tagname="menu" tagprefix="uc1" %>
<%@ register assembly="BusyBoxDotNet" namespace="BusyBoxDotNet" tagprefix="busyboxdotnet" %>
<%@ import namespace="System.Data.SqlClient" %>
<%@ import namespace="System.Data" %>
<%@ import namespace="System.Data.OracleClient" %>
<%@ import namespace="System.Data.OracleClient.OracleConnection" %>
<%@ import Namespace="System.Web.Mail" %>
<%@ import namespace="System.IO" %>
<%@ import namespace="Microsoft.VisualBasic.FileIO" %>

<script runat="server">
    Public conexion As conexiones = New conexiones
    Private lines As New List(Of String)()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If User.Identity.IsAuthenticated Then
            Dim strClientIP As String
            strClientIP = Request.UserHostAddress()
            ip.Value = strClientIP
            usuario.Value = User.Identity.Name
            If User.IsInRole("Administrador") Or User.IsInRole("P COM Ases") Or User.IsInRole("Asesor Porta *888") Or User.IsInRole("Supervisor Porta") Or User.IsInRole("Asesor Pymes") Or User.IsInRole("Asesor Pymes Back") or User.IsInRole("Apl Reposicion Sim") Then
                Label4.Text = Profile.Nombre & "  " & Profile.Apellido & " " & "[" & User.Identity.Name & "]"
            Else
                Response.Redirect("/portalsco/login.aspx?ReturnUrl=/portalsco/webpages/atv/reposicion_sim/ingreso.aspx")
            End If
        Else
            Response.Redirect("/portalsco/login.aspx?ReturnUrl=/portalsco/webpages/atv/reposicion_sim/ingreso.aspx")
        End If
        valida.Visible = False
    End Sub
      
    Protected Sub guardar_click(ByVal sender As Object, ByVal e As System.EventArgs)
        valida.Visible = False
        '8957 - CIM GORTIZ - Validar numero de lineas insertadas

        Dim contador As Integer = Convert.ToInt32(celular.Text.ToString())
        Dim region As String = ddl_region.SelectedValue


        If region = "UIO" Then
            region = "R1"
        Else
            region = "R2"
        End If

        ds_guardar.InsertParameters.Item("region").DefaultValue = region
		ds_guardar.InsertParameters.Item("telf_contacto").DefaultValue = "0999999999"
		ds_guardar.InsertParameters.Item("telf_contacto2").DefaultValue = "0999999999"
	

        If Tipo.SelectedValue = "V" Then
            If contador = 0 Then
                valida.Visible = True
                valida.Text = "Al menos debe agregar un numero de telefono en la observación de la solicitud."
            Else
                Dim result As New StringBuilder()
                For Each item As String In lines
                    Dim fields As String() = item.Split(","c)
                    Dim linea As String = fields(0)
                    If linea <> "" Then
                        result.Append(linea).Append(" ")
                    End If
                Next
                Dim formattedResult As String = result.ToString().Trim().Replace(" ", "-")
                num_repo_v.Text = formattedResult
                ds_guardar.Insert()
                'Response.Redirect("consulta.aspx")
            End If
        End If


        If Tipo.SelectedValue = "P" Then                     
            Dim codig As TextBox = New TextBox
            Dim c_req As TextBox = New TextBox
            Dim n_tram As TextBox = New TextBox
            c_req.Text = 25
            n_tram.Text = "9999"
            Dim re As SqlDataReader = conexion.traerDataReader("select top 1 codigo from tbl_pymes_clientes where ced_ruc='" & ced_ruc.Text & "' and estado='A' order by codigo desc", 3)
            If re.HasRows Then
                '8957 - CIM GORTIZ - Se valida que minimo ingrese un  numero de detalle de solicitud
                If contador = 0 Then
                    valida.Visible = True
                    valida.Text = "Al menos debe agregar un numero de telefono en el detalle de la solicitud."
                Else
                    ds_guardar.Insert()
                    'Response.Redirect("consulta.aspx")
                    'Response.Write(telf_contactos2.text,"-",telf_contactos.text,"-",correos.text,"-",nom_cont.text,"-",dir.text,"-",region.text)
                End If
            Else
                valida.Visible = True
                valida.Text = "El RUC NO pertenece a ningun cliente Corporativo."
            End If
        End If
    End Sub

    
    Protected Sub ds_guardar_Inserted(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceStatusEventArgs)
		'Response.Write("1")	
		'valida.Visible = False    
        Dim conn As SqlConnection = New SqlConnection(ConfigurationManager.ConnectionStrings("intr_callConnectionString").ConnectionString)
        Dim cmd As SqlCommand = New SqlCommand()
        Dim codigo As Integer = e.Command.Parameters("@return_id").Value
        Dim cod_sim As TextBox = New TextBox
        cod_sim.Text = codigo
        Dim obs As TextBox = Panel1.FindControl("observacion")
        'Response.Write("2")

	'Se registra informacion del CSV
	Dim lines2 () as String = contenidoCSV.Text.ToString().Split("|"c)
        'Response.Write(" VALOR2: " & lines2.Count & " ")
	If lines2.Count > 0 Then
            Dim contador As Integer = 0
            For Each line As String In lines2
                If Not String.IsNullOrEmpty(line) then
		Dim data As String() = line.Split(",")
                Dim telefono_repsim As String = data(0)
                Dim num_simcard As String = data(1)
                Dim motivorepsim as String = "L"
                Dim tipo_chip As String = "C"
				
		'Response.Write("telefono_repsim: " & telefono_repsim & " num_simcard: " & num_simcard & " cod_sim: " & cod_sim.text)
        
                ds_con_det.InsertParameters.Item("usuario_Registro").DefaultValue = User.Identity.Name
		ds_con_det.InsertParameters("telefono_repsim").DefaultValue = telefono_repsim
                ds_con_det.InsertParameters("num_simcard").DefaultValue = num_simcard
                ds_con_det.InsertParameters("motivo_repsim").DefaultValue = motivorepsim
                ds_con_det.InsertParameters("tipochp_repsim").DefaultValue = tipo_chip
                ds_con_det.InsertParameters("id_sim").DefaultValue = cod_sim.text
                ds_con_det.Insert()
				End if

            Next
            Else
            valida.Visible = True
            valida.Text = "El archivo 'CSV' está vacía. No se han encontrado datos para realizar la insercion masiva."
        End If
		
        If Tipo.SelectedValue = "P" or Tipo.SelectedValue = "V" Then
      
            cmd.Connection = conn
            cmd.CommandText = "atv_reposicion_sim_ingreso"
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("id_padre", codigo)
            cmd.Parameters.AddWithValue("usuario", usuario.Value)
            cmd.Parameters.AddWithValue("ip", ip.Value)
            cmd.Parameters.AddWithValue("observacion", obs.Text)
        	cmd.Parameters.AddWithValue("asesor", "")
            Dim rowCount As Integer
            Dim previousConnectionState As ConnectionState
            previousConnectionState = conn.State
            Try
                If conn.State = ConnectionState.Closed Then
                    conn.Open()
                End If
                rowCount = cmd.ExecuteNonQuery()
    
            Finally
                If previousConnectionState = ConnectionState.Closed Then
                    conn.Close()
                End If
            End Try
        End If
        'Response.Write("3")	
        Dim conn5 As SqlConnection = New SqlConnection(ConfigurationManager.ConnectionStrings("intr_callConnectionString").ConnectionString)
        Dim cmd5 As SqlCommand = New SqlCommand()
        
        cmd5.Connection = conn5
        cmd5.CommandText = "atv_reposicion_sim_ing_det"
        cmd5.CommandType = CommandType.StoredProcedure
        cmd5.Parameters.AddWithValue("id_padre", codigo)
        cmd5.Parameters.AddWithValue("num_admin", txt_TelfAdministrador.Text)
        cmd5.Parameters.AddWithValue("medio", "*888")
        
        'Dim ciudad As String = "Guayaquil"
        cmd5.Parameters.AddWithValue("ciudad", "")

        Dim rowCount5 As Integer
        Dim previousConnectionState5 As ConnectionState
		'Response.Write("4")	
        previousConnectionState5 = conn5.State
            Try
            If conn5.State = ConnectionState.Closed Then
                conn5.Open()
            End If
            rowCount5 = cmd5.ExecuteNonQuery()
            Finally
            If previousConnectionState5 = ConnectionState.Closed Then
                conn5.Close()
            End If
            End Try
            
		' Funcion para el boton de btnReposicionmasivo
		'Response.Write("77")
		'Response.Write(contenidoCSV.Text.ToString())
		
		'Response.Write("555")	
        
	
	
	ds_con_det.UpdateParameters.Item("id_sim").DefaultValue = cod_sim.Text
	ds_con_det.Update()

	'22735 - Reposicion SIMCARD corporativo - actualiza solicitud a pendiente
        Dim estadoP as String = "X"
        ds_actualizar_sol.UpdateParameters.Item("estado").DefaultValue = estadoP
        ds_actualizar_sol.UpdateParameters.Item("id_padre_sim").DefaultValue = cod_sim.Text
        ds_actualizar_sol.Update()

	'22735 - Reposicion SIMCARD corporativo - guardar informacion en cola axis
	Dim re1 as SqlDataReader = conexion.traerDataReader("select id_sim_det, telefono_Reposicion, simcard_Reposicion from Tbl_atv_reposicion_sim_detalle where id_sim = " & cod_sim.Text, 2)
	While re1.Read
		Try
			'Variables para conexion
			Dim conn1 As System.Data.OracleClient.OracleConnection
			Dim cmd1 As System.Data.OracleClient.OracleCommand

			conn1 = New System.Data.OracleClient.OracleConnection(ConfigurationManager.ConnectionStrings("OracleAxisConnectionString").ConnectionString)
			cmd1 = New System.Data.OracleClient.OracleCommand("PORTA.CLK_REPOSICION_SIM_EN_LINEA.P_INSERTAR_BITACORA_SIM", conn1)
			cmd1.CommandType = CommandType.StoredProcedure
			
			conn1.Open()
			cmd1.Parameters.AddWithValue("PN_ID_SIM_DET", re1.GetValue(0))
			cmd1.Parameters.AddWithValue("PN_ID_SIMCARD_PR", cod_sim.Text)
			cmd1.Parameters.AddWithValue("PV_ORIGEN", "EN LINEA")
			cmd1.Parameters.AddWithValue("PV_ESTADO", "PENDIENTE")
			cmd1.Parameters.AddWithValue("PV_TELEFONO", re1.GetValue(1))
			cmd1.Parameters.AddWithValue("PV_NUMERO_SIMCARD", re1.GetValue(2))
			cmd1.Parameters.AddWithValue("PV_USUARIO", "PORTA")
			cmd1.Parameters.AddWithValue("PV_NUMERO_ADMIN", txt_TelfAdministrador.Text)
			
			conn1.Close()
			conn1.Dispose()
		Catch ex As Exception
			Response.Write("ERROR!!! " & ex.ToString())
		End Try
	End While
	re1.Close()
    
    ' PARTE DE ENVIO DE VARIABLES PARA CORREO
    EnviarCorreo(cod_sim.Text)
    correoTemporal.Visible = False

    End Sube

    ' FUNCION NUEVA PARA CORREO
    Private Sub EnviarCorreo(ByVal codigoSim As String)
    Dim msgMail As System.Web.Mail.MailMessage = New Mail.MailMessage()
    Dim correoDestino As String = correoTemporal.text

    msgMail.To = correoDestino
    msgMail.From = "reposicion_simcard@claro.com.ec;"
    msgMail.Subject = "Reposición en Linea No. tramite: " & codigoSim

    msgMail.BodyFormat = System.Web.Mail.MailFormat.Html

    Dim strBody As StringBuilder = New StringBuilder("")

    strBody.Append("<html><body><font face=Verdana, Arial, Helvetica, sans-serif size=2>")
    strBody.Append("<br>Estimado cliente,")
    strBody.Append("<br>Le notificamos que su solicitud de reposición de Simcard se ha ingresado mediante ticket # " & codigoSim & ". Su servicio estará disponible en un lapso de 30 minutos.")
    strBody.Append("<br><br>Si tiene alguna inquietud, por favor diríjala a través de nuestros canales de atención autorizados: <a href='mailto:atencionases@claro.com.ec'>atencionases@claro.com.ec</a> / *888 / *611 O mediante su Ejecutivo de Servicio asignado. Para Claro es un placer atenderle. ¡Que tenga un buen día!")
    strBody.Append("</font></body></html>")

    msgMail.Body = strBody.ToString

    System.Web.Mail.SmtpMail.Send(msgMail)

    End Sub


    '==============================================================================
    ' Fecha:            28-04-2014
    ' Proyecto:         [8957] Mejoras al registro único de clientes corporativos
    ' Lider Claro:      SIS Christian Merchán
    ' Desarrollado por: CIMA Galo Ortiz
    ' Descripcion:      Se agregan nuevos campos informativos de la solicitud:
    '                   - Region del Cliente
    '                   - Ciudad del Cliente
    '                   - Telefono Administrador de la Cuenta
    '                   - Correo Electronico del Cliente
    '==============================================================================
    Protected Sub ddl_region_SelectedIndexChanged(sender As Object, e As System.EventArgs)
        'ddl_ciudad.Items.Clear()
        'ds_ciudad.DataBind()
        'ddl_ciudad.DataSourceID = ds_ciudad.ID
        'ddl_ciudad.Items.Add("-Seleccionar-")
        'ddl_ciudad.Items.FindByText("-Seleccionar-").Value = "-1"
        'ddl_ciudad.Items.FindByText("-Seleccionar-").Selected = True
        
        'If celular.Text = "" Then
        '    celular.Text = "0"
        'End If
    End Sub

    Protected Sub upnl_Region_Load(sender As Object, e As System.EventArgs)
		
    End Sub
    
    'FUNCION DE LISTA PARA ARCHIVO .CSV
    Protected Sub btnReponeSimMasivo_Click(ByVal sender As Object, ByVal e As EventArgs)
        valida.Visible = False
        lines.Clear()
		contenidoCSV.Text = ""
        
        ' Validar que se haya seleccionado un archivo
        If FileUpload1.HasFile Then
            ' Validar que el archivo no esté vacío
            If FileUpload1.PostedFile.ContentLength > 0 Then
                ' Validar que el archivo sea de tipo CSV
                If FileUpload1.FileName.ToLower().EndsWith(".csv") Then
                    Dim contador As Integer = 0 

                    ' Leer el archivo CSV y obtener las líneas
                    Using parser As New TextFieldParser(FileUpload1.FileContent)
                        parser.TextFieldType = FieldType.Delimited
                        parser.SetDelimiters(",")

                        ' Ignorar la primera línea (encabezados)
                        parser.ReadLine()

                        While Not parser.EndOfData
                            Dim fields As String() = parser.ReadFields()

                            ' Verificar si el archivo CSV contiene los 3 campos esperados
                            If fields.Length = 3 Then
                                Dim linea As String = fields(0)
                                Dim simcard As String = fields(1)
                                Dim contacto As String = fields(2)
								
                                ' Procesar los datos según sea necesario
                                contenidoCSV.Text = linea & "," & simcard & "," & contacto & "|" & contenidoCSV.Text.ToString()
								lines.Add(linea & "," & simcard & "," & contacto)

                                contador += 1
                                celular.Text = contador.ToString()

                                ' Verificar si se ha alcanzado el limite de 50 filas
                                If contador > 50 Then
                                    valida.Visible = True
                                    valida.Text = "Se ha superado el limite de 50 filas."
                                
                                    contador = 0
                                    celular.Text = contador.ToString()

                                    Exit While
                                End If
                            End If
                        End While
                    End Using
                Else
                    valida.Visible = True
                    valida.Text = "El archivo seleccionado no es de tipo CSV."
                End If
            Else
                valida.Visible = True
                valida.Text = "El archivo CSV esta vacio."
            End If
        Else
            valida.Visible = True
            valida.Text = "No se ha seleccionado ningun archivo CSV."
        End If
        If lines.Count > 0 Then
        Dim correoDestino As String = lines(0).Split(","c)(2)
        correoTemporal.Text = correoDestino
        correoTemporal.Visible = True
        End If
    End Sub
	
	Protected Sub ds_Prueba(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceStatusEventArgs)
		Dim codigo As Integer = e.Command.Parameters("@return_id").Value
	End Sub

</script>


<script language="javascript">

    function validar_nom(source, arguments) {

        if ((arguments.Value.length == 0)) {
            alert("Por favor, indique el nombre del cliente.");
            arguments.IsValid = false;
        }
        else
            arguments.IsValid = true;
    }

    function validar_coment(source, arguments) {

        if ((arguments.Value.length == 0)) {
            alert("Por favor, especifique algun comentario adicional respecto al caso.");
            arguments.IsValid = false;
        }
        else
            arguments.IsValid = true;
    }

    function validar_region(source, arguments) {
        //Se valida la seleccion de la región del cliente
        if (arguments.Value == "-1") {
            alert("Por favor, seleccione la región del cliente.");
            arguments.IsValid = false;
        }
        else
            arguments.IsValid = true;
    }

    function validar_cta(source, arguments) {

        if ((arguments.Value.length < 6)) {
            alert("Por favor, indique el número de cuenta.");
            arguments.IsValid = false;
        }
        else
            arguments.IsValid = true;
    }

    function validar_num(source, arguments) {

        if ((arguments.Value.length < 9)) {
            alert("Por favor, ingrese el número celular completo.");
            arguments.IsValid = false;
        }
        else
            arguments.IsValid = true;
    }

    function validar_telf_adm(source, arguments) {
        //Se valida el ingreso de los 10 numeros del telefono administrador 
        if ((arguments.Value.length < 10)) {
            alert("Por favor, ingrese los 10 digitos del telefono administrador.");
            arguments.IsValid = false;
        }
        else
            arguments.IsValid = true;
    }

</script>


<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">

    <title>Reposici&#243;n de Simcard | Ingreso</title>
    <script language="javascript" src="/portalsco/include/js/calendar/popcalendar.js"></script>
    <link href="/portalsco/include/js/calendar/popcalendar.css" type="text/css" rel="stylesheet">
    <style type="text/css">
        .style2 {
            height: 68px;
        }

        .style3 {
            height: 14px;
        }

        .style4 {
            height: 38px;
        }

        .style5 {
            height: 22px;
        }

        .style6 {
            color: #000000;
        }
    </style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
    <form id="form1" runat="server">
        <strong><span style="color: #ff0000">
            <table cellpadding="0" cellspacing="0" style="height: 88px" width="100%">
                <tbody>
                    <tr>
                        <td background="../../../images/apl/simcard.jpg"></td>
                    </tr>
                </tbody>
            </table>
            <uc1:menu id="Menu1" runat="server" /></strong>
        <asp:Panel ID="Panel1" runat="server" Width="100%" SkinID="porta" HorizontalAlign="Center">
            <br />
            <br />
            <br />

            <table style="width: 800px" align="center">
                <tr>
                    <td>
                        <strong><span style="color: #000000">Fecha:</span></strong></td>
                    <td><%=FormatDateTime(Date.Now,DateFormat.LongDate)%>
                    </td>
                    <td>
                        <strong><span style="color: #000000"></span></strong></td>
                    <td></td>
                </tr>
                <tr>
                    <td>
                        <strong><span style="color: #000000">Login:</span></strong></td>
                    <td>
                        <asp:Label ID="Label4" runat="server" Text="Label" Font-Bold="False" ForeColor="DimGray"></asp:Label>
                    </td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td style="height: 29px" colspan="4">
                        <strong><span style="color: #000000"></span></strong>
                        <hr style="color: silver; height: 3px" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <%-- TIPO DE CLIENTE  --%>
                        <strong><span style="color: #000000">Tipo Cliente:</span></strong></td>
                    <td align="left">
                        <asp:RadioButtonList ID="Tipo" runat="server" RepeatDirection="Horizontal" Width="144px" AutoPostBack="True">
                            <asp:ListItem Value="V" Selected="True">VIP</asp:ListItem>
                            <asp:ListItem Value="P">PYMES</asp:ListItem>
                        </asp:RadioButtonList>
                    </td>
                    <%-- RUC --%>
                    <td class="style6">
                        <strong>RUC:&nbsp;</strong></td>
                    <td>
                        <asp:TextBox ID="ced_ruc" runat="server" MaxLength="13"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <%-- NOMBRE DEL CLIENTE --%>
                        <strong><span style="color: #000000">Nombre del Cliente:</span></strong></td>
                    <td>
                        <asp:TextBox ID="nombre" runat="server" MaxLength="60" Width="249px"></asp:TextBox>
                        <asp:CustomValidator ID="CustomValidator4" runat="server" ClientValidationFunction="validar_nom"
                            ControlToValidate="nombre" ErrorMessage="*" SetFocusOnError="True" ValidateEmptyText="True">
                        </asp:CustomValidator>
                    </td>
                    <td>
                        <%-- CUENTA AXIS --%>
                        <strong><span style="color: #000000">Cuenta Axis:</span></strong></td>
                    <td>
                        <asp:TextBox ID="cta_axis" runat="server" MaxLength="10" onkeypress="if ((event.keyCode > 0 && event.keyCode < 46)|| (event.keyCode == 47)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                            Width="81px">
                        </asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <%--8957 - REGION DEL CLIENTE--%>
                    <td>
                        <strong><span style="color: #000000">Region del Cliente:</span></strong></td>
                    <td>
                        <span style="color: #ff0000">
                            <asp:DropDownList ID="ddl_region" runat="server" AppendDataBoundItems="True"
                                AutoPostBack="True" OnSelectedIndexChanged="ddl_region_SelectedIndexChanged">
                                <asp:ListItem Selected="True" Value="-1">-Seleccionar-</asp:ListItem>
                                <asp:ListItem Value="UIO">R1-UIO</asp:ListItem>
                                <asp:ListItem Value="GYE">R2-GYE</asp:ListItem>
                            </asp:DropDownList>
                            <asp:CustomValidator ID="cv_RegionCliente" runat="server"
                                ClientValidationFunction="validar_region" ControlToValidate="ddl_region"
                                ErrorMessage="*" SetFocusOnError="True" ValidateEmptyText="True">
                            </asp:CustomValidator>
                        </span>
                </tr>
                <tr>
                    <%--8957-TELEFONO ADMINISTRADOR AXIS--%>
                    <td class="style4">
                        <span style="color: #ff0000"><strong><span style="color: #000000">
                            <asp:CheckBox ID="CheckBox1" runat="server" AutoPostBack="True" Enabled="False"
                                Text="Números Adicionales Reposición:" Visible="False" />
                        </span></strong></span></td>
                    <td class="style4">
                        <span style="color: #ff0000">
                            <asp:TextBox ID="num_repo_v" runat="server" Columns="7" Enabled="False"
                                Height="28px" MaxLength="99"
                                onkeypress="if ((event.keyCode &gt; 0 &amp;&amp; event.keyCode &lt; 32)|| (event.keyCode &gt; 33 &amp;&amp; event.keyCode &lt; 35) ||(event.keyCode &gt; 38 &amp;&amp; event.keyCode &lt; 40) ||(event.keyCode &gt; 95 &amp;&amp; event.keyCode &lt; 97) ||(event.keyCode &gt; 125 &amp;&amp; event.keyCode &lt; 129) || (event.keyCode &gt; 165 &amp;&amp; event.keyCode &lt; 256)) event.returnValue = false;"
                                Rows="5" TextMode="MultiLine" Visible="False" Width="115px">
                            </asp:TextBox>
                            <asp:TextBox ID="celular" runat="server" MaxLength="9"
                                onkeypress="if ((event.keyCode &gt; 0 &amp;&amp; event.keyCode &lt; 48)|| (event.keyCode &gt; 57 &amp;&amp; event.keyCode &lt; 256)) event.returnValue = false;"
                                Visible="False" Width="68px" AutoPostBack="True">
                            </asp:TextBox>
                        </span></td>
                    <td class="style4">
                        <span style="color: #ff0000"><strong><span style="color: #000000">
                            <asp:Label ID="lbl_TelfAdmCuenta" runat="server"
                                Text="Telf. Administrador cuenta Axis:"></asp:Label>
                        </span></strong></span>
                    </td>
                    <td class="style4">
                        <span style="color: #ff0000">
                            <asp:TextBox ID="txt_TelfAdministrador" runat="server" MaxLength="10"
                                onkeypress="if ((event.keyCode &gt; 0 &amp;&amp; event.keyCode &lt; 48)|| (event.keyCode &gt; 57 &amp;&amp; event.keyCode &lt; 256)) event.returnValue = false;"
                                Width="100px">
                            </asp:TextBox>
                            <asp:CustomValidator ID="cv_TelfAdministrador" runat="server"
                                ClientValidationFunction="validar_telf_adm" ControlToValidate="txt_TelfAdministrador"
                                ErrorMessage="*" SetFocusOnError="True" ValidateEmptyText="True">
                            </asp:CustomValidator>
                        </span>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:TextBox ID="contenidoCSV" runat="server" Visible="False"></asp:TextBox>
                    </td>
                </tr>
            </table>

            <span style="color: #ff0000">
                <br />
            </span>
            <asp:Label ID="valida" runat="server" Font-Bold="True" Font-Size="10pt"></asp:Label>
            <br />
            <br />
            
            <%-- OBSERVACIONES --%>
            <strong><span style="color: #000000">Observaciones:</span><br />
            </strong>
            <asp:TextBox ID="observacion" runat="server" MaxLength="500"
                Rows="6" TextMode="MultiLine"
                Width="380px" Height="54px">
            </asp:TextBox>
            <br />
            <asp:CustomValidator ID="CustomValidator5" runat="server" ClientValidationFunction="validar_coment"
                ControlToValidate="observacion" SetFocusOnError="True" ValidateEmptyText="True">
            </asp:CustomValidator>
            <br />
            <br />
            <br />

            <asp:FileUpload ID="FileUpload1" runat="server" />
            <br />
            <br />
            <asp:Button ID="btnReponeSimMasivo" runat="server" Text="REPONE SIMCARD MASIVO" OnClick="btnReponeSimMasivo_Click" Font-Bold="True" ForeColor="#0000FF" />

            <br />
            <br />
            <asp:Button ID="grabar" runat="server" Text="Grabar" OnClick="guardar_click" Font-Bold="True" ForeColor="#000000" />
            <asp:TextBox ID="correoTemporal" runat="server" Visible="False"></asp:TextBox>
            <br />
            <br />
            <br />

        </asp:Panel>
        &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;

        <%-- DATA SOURCE PARA GUARDAR --%>
        <asp:SqlDataSource ID="ds_guardar" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
            InsertCommand="INSERT INTO Tbl_atv_reposicion_sim
(fecha_ing, nom_ases, nom_cliente, cta_axis,  num_repo, login, ip, observacion, num_repo_v, tipo, region_cliente,telf_contacto,telf_contacto2)
VALUES
(GETDATE(), '-', @nom_cliente, @cta_axis, '0'+@num_repo, @login, @ip, @observacion, '-'+@num_repo_v,@tipo, @region,@telf_contacto,@telf_contacto2)
; select @return_id=scope_identity()"
            OnInserted="ds_guardar_Inserted">
            <insertparameters>
                <asp:ControlParameter ControlID="nombre" Name="nom_cliente" PropertyName="Text" />
                <asp:ControlParameter ControlID="cta_axis" Name="cta_axis" PropertyName="Text" />
                <asp:ControlParameter ControlID="celular" Name="num_repo" PropertyName="Text" />
                <asp:ControlParameter ControlID="num_repo_v" Name="num_repo_v" PropertyName="Text" />
                <asp:ControlParameter ControlID="usuario" Name="login" PropertyName="Value" />
                <asp:ControlParameter ControlID="ip" Name="ip" PropertyName="Value" />
                <asp:ControlParameter ControlID="observacion" Name="observacion" PropertyName="Text" />
                <asp:Parameter Name="region" />
                <asp:Parameter Name="telf_contacto" />
                <asp:Parameter Name="telf_contacto2" />
                <asp:Parameter Name="return_id" Type="Int32" Direction="InputOutput" />
                <asp:ControlParameter ControlID="Tipo" Name="tipo" PropertyName="SelectedValue" />
            </insertparameters>
        </asp:SqlDataSource>
        <busyboxdotnet:busybox id="BusyBox1" runat="server" slideduration="900" text="Por favor espere mientras se procesan los datos." title="Portal SCO" />
        <asp:SqlDataSource ID="grab_pymes" runat="server" ConnectionString="<%$ ConnectionStrings:CRMConnectionString %>"
            SelectCommand="s"></asp:SqlDataSource>
        <asp:SqlDataSource ID="ds_ases" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
            SelectCommand="select username, E.nombre+' '+E.apellido as usuario&#13;&#10;from aspnet_users A&#13;&#10;inner join aspnet_usersinroles B on A.userid=B.userid&#13;&#10;inner join aspnet_roles C on B.roleid=C.roleid&#13;&#10;inner join aspnet_membership D on A.userid=D.userid&#13;&#10;inner join aspnet_perfiles E on A.userid=E.userid&#13;&#10;where c.rolename='P COM Ases' and D.isapproved='1'&#13;&#10;order by e.nombre, e.apellido"></asp:SqlDataSource>
        &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
        &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
        &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
        &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
        <asp:HiddenField ID="usuario" runat="server" />
        <asp:HiddenField ID="ip" runat="server" />
        <asp:HiddenField ID="mail" runat="server" />


        <%-- DATA SOURCE PARA LA TABLA --%>
        <asp:SqlDataSource ID="ds_con_det" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
            SelectCommand="SELECT id_sim_det, telefono_Reposicion, CASE motivo_Reposicion WHEN 'R' THEN 'Robo' WHEN 'A' THEN 'Daño/Perdida' WHEN 'S' THEN 'Stock de simcard' END AS motivo_Reposicion, CASE tipochip_Reposicion WHEN 'C' THEN 'Simcard Normal' WHEN 'M' THEN 'Mini Simcard' WHEN 'I' THEN 'Micro Simcard' WHEN 'N' THEN 'Nano Simcard' END AS tipochip_Reposicion, fecha_Registro FROM Tbl_atv_reposicion_sim_detalle WHERE (id_CuentaAxis = @ctaAxis) AND (estado = 'P') ORDER BY id_sim_det"
            CancelSelectOnNullParameter="False"
            InsertCommand="INSERT INTO Tbl_atv_reposicion_sim_detalle(id_CuentaAxis, telefono_Reposicion, motivo_Reposicion, tipochip_Reposicion, fecha_Registro, usuario_Registro, estado, simcard_Reposicion, id_sim) VALUES (@id_CuentaAxis, @telefono_repsim, @motivo_repsim, @tipochp_repsim, getdate(), @usuario_Registro, 'P', @num_simcard, @id_sim)
			; select @return_id=scope_identity()"
            OnInserted="ds_Prueba"
            DeleteCommand="DELETE FROM Tbl_atv_reposicion_sim_detalle WHERE (id_sim_det = @id_sim_det) AND (estado = 'P')"
            UpdateCommand="UPDATE Tbl_atv_reposicion_sim_detalle SET estado = 'F' WHERE (id_sim = @id_sim) AND (estado = 'P')">
            <deleteparameters>
                <asp:Parameter Name="id_sim_det" />
            </deleteparameters>
            <insertparameters>
                <asp:Parameter Name="id_CuentaAxis" />
                <asp:Parameter Name="telefono_repsim" />
                <asp:Parameter Name="num_simcard" />
                <asp:Parameter Name="motivo_repsim" />
                <asp:Parameter Name="tipochp_repsim" />
                <asp:Parameter Name="usuario_Registro" />
                <asp:Parameter Name="id_sim" />
                <asp:Parameter Name="return_id" Type="Int32" Direction="InputOutput" />
            </insertparameters>
            <selectparameters>
                <asp:ControlParameter ControlID="cta_axis" DefaultValue="" Name="ctaAxis" PropertyName="Text" />
            </selectparameters>
            <updateparameters>
                <asp:Parameter Name="id_sim" />
            </updateparameters>
        </asp:SqlDataSource>

        <%--22735 - DATASOURCE ACTUALIZAR SOLICITUD A PENDINETE --%>
        <asp:SqlDataSource ID="ds_actualizar_sol" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
            UpdateCommand="UPDATE Tbl_atv_reposicion_sim_proceso SET ultimo_estado = @estado WHERE id_padre = @id_padre_sim">
            <updateparameters>
                <asp:Parameter Name="estado" />
                <asp:Parameter Name="id_padre_sim" />
            </updateparameters>
        </asp:SqlDataSource>

        <%--22735 - DATASOURCE PARA LA NUEVA TABLA SQL SERVER --%>
        <asp:SqlDataSource ID="ds_guardar_cola" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
            InsertCommand="INSERT INTO Tbl_atv_reposicion_sim_cola
(id_simcard_cola, id_simcard_pr, origen, estado, respuesta_ws, fecha_programada, usuario_registro, fecha_registro, usuario_modificacion, fecha_modificacion)
VALUES
(scope_identity(), @id_simcard_pr, @origen, @estado, @respuesta_ws, @fecha_programada, @usuario_registro, @fecha_registro, @usuario_modificacion, @fecha_modificacion);">
            <insertparameters>
                <asp:ControlParameter Name="id_simcard_pr" />
                <asp:ControlParameter Name="origen" />
                <asp:ControlParameter Name="estado" />
                <asp:ControlParameter Name="respuesta_ws" />
                <asp:ControlParameter Name="fecha_programada" />
                <asp:ControlParameter Name="usuario_registro" />
                <asp:ControlParameter Name="fecha_registro" />
                <asp:ControlParameter Name="usuario_modificacion" />
                <asp:ControlParameter Name="fecha_modificacion" />
            </insertparameters>
        </asp:SqlDataSource>
        <busyboxdotnet:busybox id="BusyBox2" runat="server" slideduration="900" text="Por favor espere mientras se procesan los datos." title="Portal SCO" />
        &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
        &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
        &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
        &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;

    </form>
</body>
</html>
