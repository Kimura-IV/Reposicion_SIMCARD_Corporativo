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

<script runat="server">
    Public conexion As conexiones = New conexiones
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
        
        If CheckBox1.Checked Then
            num_repo_v.Enabled = True
        Else
            num_repo_v.Enabled = False
        End If
        '8957 - CIM GORTIZ - Reiniciar combo de ciudades
        If celular.Text = "" Then
            ddl_ciudad.Items.Clear()
            ds_ciudad.DataBind()
            ddl_ciudad.DataSourceID = ds_ciudad.ID
            ddl_ciudad.Items.Add("-Seleccionar-")
            ddl_ciudad.Items.FindByText("-Seleccionar-").Value = "-1"
            ddl_ciudad.Items.FindByText("-Seleccionar-").Selected = True
        End If
    End Sub

    Protected Sub TIPO_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If TIPO.SelectedValue = "P" Then
            ases.Visible = False
            asesor.Visible = False
        Else
            ases.Visible = True
            asesor.Visible = True
        End If
    End Sub
      
    Protected Sub guardar_click(ByVal sender As Object, ByVal e As System.EventArgs)
        valida.Visible = False
        '8957 - CIM GORTIZ - Validar numero de lineas insertadas
        Dim contador As Integer = Convert.ToInt32(celular.Text.ToString())
        Dim region As String = ddl_region.SelectedValue


        Dim nom_ases As String = Nothing
        Dim direccion As String = Nothing
        Dim num_repo_v As String = Nothing
        Dim nom_contacto As String = Nothing
        Dim correo As String = Nothing
        Dim telf_contacto As String = Nothing
        Dim telf_contacto2 As String = Nothing


        If region = "UIO" Then
            region = "R1"
        Else
            region = "R2"
        End If

        ds_guardar.InsertParameters.Item("region").DefaultValue = region


        ds_guardar.InsertParameters.Item("nom_ases").DefaultValue = ases
        ds_guardar.InsertParameters.Item("direccion").DefaultValue = dir
        ds_guardar.InsertParameters.Item("num_repo_v").DefaultValue = num_repo_v
        ds_guardar.InsertParameters.Item("nom_contacto").DefaultValue = nom_contacto
        ds_guardar.InsertParameters.Item("correo").DefaultValue = txt_CorreoCliente
        ds_guardar.InsertParameters.Item("telf_contacto").DefaultValue = telf_contacto
        ds_guardar.InsertParameters.Item("telf_contacto2").DefaultValue = contacto2
        
        
        If Tipo.SelectedValue = "V" Then
            If contador = 0 Then
                valida.Visible = True
                valida.Text = "Al menos debe agregar un numero de telefono en la observación de la solicitud."
            Else
                Dim lbl_tlf_rep_tmp As Label
                Dim therowindex As Integer = 0
        
                For Each row As GridViewRow In gv_lineas_solicitud.Rows()
                    therowindex = row.RowIndex
                    lbl_tlf_rep_tmp = DirectCast(gv_lineas_solicitud.Rows(therowindex).FindControl("lbl_num_rep_det"), Label)
                    If lbl_tlf_rep_tmp.Text <> "" Then
                        num_repo_v.Text = num_repo_v.Text.ToString() + lbl_tlf_rep_tmp.Text.ToString() + " "
                    End If
                Next
                num_repo_v.Text = num_repo_v.Text.ToString().Trim()
                num_repo_v.Text = num_repo_v.Text.ToString().Replace(" ", "-")
                ds_guardar.Insert()
                Response.Redirect("consulta.aspx")
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
                    Response.Redirect("consulta.aspx")
                End If
            Else
                valida.Visible = True
                valida.Text = "El RUC NO pertenece a ningun cliente Corporativo."
            End If
        End If
    End Sub
    
    Protected Sub ds_guardar_Inserted(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceStatusEventArgs)
        Dim conn As SqlConnection = New SqlConnection(ConfigurationManager.ConnectionStrings("intr_callConnectionString").ConnectionString)
        Dim cmd As SqlCommand = New SqlCommand()
        Dim codigo As Integer = e.Command.Parameters("@return_id").Value
        Dim cod_sim As TextBox = New TextBox
        cod_sim.Text = codigo
        Dim obs As TextBox = Panel1.FindControl("observacion")
        Dim ase As DropDownList = Panel1.FindControl("ases")
        
        If Tipo.SelectedValue = "V" Then
            cmd.Connection = conn
            cmd.CommandText = "atv_reposicion_sim_ingreso"
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("id_padre", codigo)
            cmd.Parameters.AddWithValue("usuario", usuario.Value)
            cmd.Parameters.AddWithValue("ip", ip.Value)
            cmd.Parameters.AddWithValue("observacion", obs.Text)
            cmd.Parameters.AddWithValue("asesor", ase.SelectedValue)
        
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
               
        If Tipo.SelectedValue = "P" Then
          
            cmd.Connection = conn
            cmd.CommandText = "atv_reposicion_sim_ingreso"
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("id_padre", codigo)
            cmd.Parameters.AddWithValue("usuario", usuario.Value)
            cmd.Parameters.AddWithValue("ip", ip.Value)
            cmd.Parameters.AddWithValue("observacion", obs.Text)
            cmd.Parameters.AddWithValue("asesor", ase.SelectedValue)
        
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
       
        '8957 - CIM GORTIZ - Se actualiza tramite en tabla de detalle
        ds_con_det.UpdateParameters.Item("id_sim").DefaultValue = cod_sim.Text
        For Each row As GridViewRow In gv_lineas_solicitud.Rows()
            Dim therowindex As Integer = row.RowIndex
            Dim theid As Integer = gv_lineas_solicitud.DataKeys([therowindex]).Value
            ds_con_det.UpdateParameters.Item("id_sim_det").DefaultValue = theid.ToString()
            ds_con_det.Update()
        Next
        
        Dim conn5 As SqlConnection = New SqlConnection(ConfigurationManager.ConnectionStrings("intr_callConnectionString").ConnectionString)
        Dim cmd5 As SqlCommand = New SqlCommand()
        
        cmd5.Connection = conn5
        cmd5.CommandText = "atv_reposicion_sim_ing_det"
        cmd5.CommandType = CommandType.StoredProcedure
        cmd5.Parameters.AddWithValue("id_padre", codigo)
        cmd5.Parameters.AddWithValue("num_admin", txt_TelfAdministrador.Text)
        cmd5.Parameters.AddWithValue("medio", "*888")
        
        Dim ciudad As String = Nothing
        cmd5.Parameters.AddWithValue("ciudad", ciudad)

        Dim rowCount5 As Integer
        Dim previousConnectionState5 As ConnectionState
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
        ddl_ciudad.Items.Clear()
        ds_ciudad.DataBind()
        ddl_ciudad.DataSourceID = ds_ciudad.ID
        ddl_ciudad.Items.Add("-Seleccionar-")
        ddl_ciudad.Items.FindByText("-Seleccionar-").Value = "-1"
        ddl_ciudad.Items.FindByText("-Seleccionar-").Selected = True
        
        If celular.Text = "" Then
            celular.Text = "0"
        End If
    End Sub

    Protected Sub upnl_Region_Load(sender As Object, e As System.EventArgs)

    End Sub


    Protected Sub btnMostrarTabla_Click(ByVal sender As Object, ByVal e As EventArgs)
    tablaReposicion.Visible = True
    End Sub
    
    'FORMA 1 - PARA AGG A UNA LISTA
    Protected Sub btnReponeSimMasivo_Click(ByVal sender As Object, ByVal e As EventArgs)
        ' Validar que se haya seleccionado un archivo
    If FileUpload1.HasFile Then
        ' Validar que el archivo no esté vacío
        If FileUpload1.PostedFile.ContentLength > 0 Then
            Dim lines As New List(Of String)()
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
        ' Por ejemplo, puedes agregarlos a una lista
        lines.Add($"{linea},{simcard},{contacto}")

        ' Incrementar el contador
        contador += 1

        ' Verificar si se ha alcanzado el límite de 50 filas
                        If contador >= 50 Then
                            Exit While
                        End If
                    End If
                End While
            End Using

        ' Mostrar mensaje de éxito o redireccionar a otra página
        Response.Write("Se ha leído el archivo CSV exitosamente.")
        Else
        ' Mostrar mensaje de error si el archivo está vacío
        Response.Write("El archivo CSV está vacío.")
        End If
        Else
        ' Mostrar mensaje de error si no se seleccionó un archivo
        Response.Write("No se ha seleccionado ningún archivo CSV.")
    End If
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

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">

    <title>Reposición de Simcard | Ingreso</title>
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
                        <asp:Label ID="Label4" runat="server" Text="Label" Font-Bold="False" ForeColor="DimGray"></asp:Label></td>
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
                        <strong><span style="color: #000000">Tipo Cliente:</span></strong></td>
                    <td align="left">
                        <asp:RadioButtonList ID="Tipo" runat="server" OnSelectedIndexChanged="TIPO_SelectedIndexChanged"
                            RepeatDirection="Horizontal" Width="144px" AutoPostBack="True">
                            <asp:ListItem Value="V" Selected="True">VIP</asp:ListItem>
                            <asp:ListItem Value="P">PYMES</asp:ListItem>
                        </asp:RadioButtonList></td>
                    <td class="style6">
                        <strong>RUC:&nbsp;</strong></td>
                    <td>
                        <asp:TextBox ID="ced_ruc" runat="server" MaxLength="13"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <strong><span style="color: #000000">Nombre del Cliente:</span></strong></td>
                    <td>
                        <asp:TextBox ID="nombre" runat="server" MaxLength="60" Width="249px"></asp:TextBox>
                        <asp:CustomValidator ID="CustomValidator4" runat="server" ClientValidationFunction="validar_nom"
                            ControlToValidate="nombre" ErrorMessage="*" SetFocusOnError="True" ValidateEmptyText="True"></asp:CustomValidator></td>
                    <td>
                        <strong><span style="color: #000000">Cuenta Axis:</span></strong></td>
                    <td>
                        <asp:TextBox ID="cta_axis" runat="server" MaxLength="10" onkeypress="if ((event.keyCode > 0 && event.keyCode < 46)|| (event.keyCode == 47)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                            Width="81px"></asp:TextBox>
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
            </table>

            <%--CIM GORTIZ - PANEL INGRESO DETALLE DE LINEAS MINIMO 1 MAXIMO 10--%>
            <asp:Panel ID="pnl_DetalleSolicitud" runat="server">
                <br />
                <table id="tablaReposicion" align="center" border="0" style="border: thin ridge #FF0000; width: 27%; display: none;">
                    <tr>
                        <td class="style3" colspan="5" align="center" bgcolor="#CC0000"
                            style="color: #FFFFFF">Reposición Individual</td>
                    </tr>
                    <tr align="center">
                        <td class="style10" align="center" bgcolor="#CCCCCC">
                            <asp:Label ID="lbl_Det_NumRep" runat="server" Text="Numero de línea"></asp:Label>
                        </td>
                        <td class="style12" align="center" bgcolor="#CCCCCC">
                            <asp:Label ID="lbl_Det_MotRep" runat="server" Text="Numero de Simcard"></asp:Label>
                        </td>
                        <td class="style13" align="center" bgcolor="#CCCCCC">
                            <asp:Label ID="lbl_Det_TipRep" runat="server" Text="Celular/Correo Administrador"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td class="style3">
                            <asp:TextBox ID="txt_Det_NumRep" runat="server" Height="19px" Width="91px"></asp:TextBox>
                        </td>
                        <td class="style3">
                            <asp:TextBox ID="txt_Det_NumRep1" runat="server" Height="19px" Width="91px"></asp:TextBox>
                        </td>
                        <td class="style3">
                            <asp:TextBox ID="txt_Det_NumRep2" runat="server" Height="19px" Width="91px"></asp:TextBox>
                        </td>
                    </tr>
                </table>
            </asp:Panel>

            <span style="color: #ff0000">
                <br />
            </span>

            <asp:Label ID="valida" runat="server" Font-Bold="True" Font-Size="10pt"></asp:Label><br />
            
            <br />
            <strong><span style="color: #000000">Observaciones:</span><br />
            
            </strong>
            
            <asp:TextBox ID="observacion" runat="server" MaxLength="500"
                Rows="6" TextMode="MultiLine"
                Width="380px" Height="54px"></asp:TextBox>
            
            <br />
            <asp:CustomValidator ID="CustomValidator5" runat="server" ClientValidationFunction="validar_coment"
                ControlToValidate="observacion" SetFocusOnError="True" ValidateEmptyText="True"></asp:CustomValidator><br />
            <br />

            <asp:Button ID="btnMostrarTabla" runat="server" Text="REPONE SIMCARD" OnClick="btnMostrarTabla_Click" />
            <asp:Button ID="btnReponeSimMasivo" runat="server" Text="REPONE SIMCARD MASIVO" />

            <br />
            <br />
            <asp:Button ID="grabar" runat="server" Text="Grabar" OnClick="guardar_click" Font-Bold="True" ForeColor="#000000" /><br />
            <br />
            <br />

        </asp:Panel>
        &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;

        
        <%--DATA SOURCE PARA LA CIUDAD FALTA EDITAR--%>
        <asp:SqlDataSource ID="ds_ciudad" runat="server" ConnectionString="<%$ ConnectionStrings:CRMConnectionString %>"
            SelectCommand="SELECT DISTINCT ( b.po_descripcion + ' - ' + a.desc_area ) AS Nombre, a.desc_area AS Id 
FROM  intr_call.dbo.Tbl_D_CodigoArea a
INNER JOIN  intr_call.dbo.Tbl_M_provincia b ON a.po_codigo = b.po_codigo 
WHERE (a.codigo_pais = 18)
and a.region in ('GYE', 'UIO', '---')
and (@id_region='-1' or (a.region=@id_region))
ORDER BY NOMBRE">
             <SelectParameters>
                 <asp:ControlParameter ControlID="ddl_region" Name="id_region" 
                     PropertyName="SelectedValue" DefaultValue="-1" />
             </SelectParameters>
        </asp:SqlDataSource> 

        
        <%--DATA SOURCE PARA GUARDAR--%>
        <asp:SqlDataSource ID="ds_guardar" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
            InsertCommand="INSERT INTO Tbl_atv_reposicion_sim
(fecha_ing, nom_ases, nom_cliente, cta_axis, direccion, nom_contacto, telf_contacto, num_repo, login, ip, observacion, num_repo_v, telf_contacto2,tipo, region_cliente, correo_cliente)
VALUES
(GETDATE(), @nom_ases, @nom_cliente, @cta_axis, @direccion, @nom_contacto, @telf_contacto, '0'+@num_repo, @login, @ip, @observacion, '-'+@num_repo_v, @telf_contacto2,@tipo, @region, @correo)
; select @return_id=scope_identity()" OnInserted="ds_guardar_Inserted">
            <InsertParameters>
                <asp:Parameter Name="nom_ases" />
                <asp:ControlParameter ControlID="nombre" Name="nom_cliente" PropertyName="Text" />
                <asp:ControlParameter ControlID="cta_axis" Name="cta_axis" PropertyName="Text" />
                <asp:Parameter Name="direccion" />
                <asp:Parameter Name="nom_contacto" />
                <asp:Parameter Name="telf_contacto" />
                <asp:Parameter Name="telf_contacto2" />
                <asp:ControlParameter ControlID="celular" Name="num_repo" PropertyName="Text" />
                <asp:Parameter Name="num_repo_v" />
                <asp:ControlParameter ControlID="usuario" Name="login" PropertyName="Value" />
                <asp:ControlParameter ControlID="ip" Name="ip" PropertyName="Value" />
                <asp:ControlParameter ControlID="observacion" Name="observacion" PropertyName="Text" />
                <asp:Parameter Name="return_id" Type="Int32" Direction="InputOutput" />
                <asp:ControlParameter ControlID="Tipo" Name="tipo" PropertyName="SelectedValue" />
                <asp:Parameter Name="region" />
                <asp:Parameter Name="correo" />
            </InsertParameters>
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
        

        <%--DATA SOURCE PARA LA TABLA FALTA EDITAR--%>
        <asp:SqlDataSource ID="ds_con_det" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
            SelectCommand="SELECT id_sim_det, telefono_Reposicion, CASE motivo_Reposicion WHEN 'R' THEN 'Robo' WHEN 'A' THEN 'Daño/Perdida' WHEN 'S' THEN 'Stock de simcard' END AS motivo_Reposicion, CASE tipochip_Reposicion WHEN 'C' THEN 'Simcard Normal' WHEN 'M' THEN 'Mini Simcard' WHEN 'I' THEN 'Micro Simcard' WHEN 'N' THEN 'Nano Simcard' END AS tipochip_Reposicion, fecha_Registro FROM Tbl_atv_reposicion_sim_detalle WHERE (id_CuentaAxis = @ctaAxis) AND (estado = 'P') ORDER BY id_sim_det"
            CancelSelectOnNullParameter="False"
            InsertCommand="INSERT INTO Tbl_atv_reposicion_sim_detalle(id_CuentaAxis, telefono_Reposicion, motivo_Reposicion, tipochip_Reposicion, fecha_Registro, usuario_Registro, estado) VALUES (@id_CuentaAxis, @telefono_repsim, @motivo_repsim, @tipochp_repsim, getdate(), @usuario_Registro, 'P')"
            DeleteCommand="DELETE FROM Tbl_atv_reposicion_sim_detalle WHERE (id_sim_det = @id_sim_det) AND (estado = 'P')"
            UpdateCommand="UPDATE Tbl_atv_reposicion_sim_detalle SET id_sim = @id_sim, estado = 'F' WHERE (id_sim_det = @id_sim_det) AND (estado = 'P')">
            <DeleteParameters>
                <asp:Parameter Name="id_sim_det" />
            </DeleteParameters>
            <InsertParameters>
                <asp:ControlParameter ControlID="cta_axis" Name="id_CuentaAxis"
                    PropertyName="Text" />
                <asp:ControlParameter ControlID="txt_Det_NumRep" Name="telefono_repsim"
                    PropertyName="Text" />
                <asp:ControlParameter ControlID="ddl_Det_MotRep" Name="motivo_repsim"
                    PropertyName="SelectedValue" />
                <asp:ControlParameter ControlID="ddl_Det_TipChip" Name="tipochp_repsim"
                    PropertyName="SelectedValue" />
                <asp:Parameter Name="usuario_Registro" />
            </InsertParameters>
            <SelectParameters>
                <asp:ControlParameter ControlID="cta_axis" DefaultValue="" Name="ctaAxis"
                    PropertyName="Text" />
            </SelectParameters>
            <UpdateParameters>
                <asp:Parameter Name="id_sim" />
                <asp:Parameter Name="id_sim_det" />
            </UpdateParameters>
        </asp:SqlDataSource>
    </form>
</body>
</html>
