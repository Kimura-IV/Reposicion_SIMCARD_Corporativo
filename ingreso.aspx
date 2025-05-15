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
***************************************************************************************************************
DESCRIPCION: 22735 - Reposicion SIMCARD corporativo
MODIFICADO POR: SUD. GVillanueva
MOTIVO DE MODIFICACIÓN: Setear solicitud como pendiente (X) - Resolución ARCOTEL-2022-0335, articulo 18.1
FECHA DE MODIFICACIÓN: 14/07/2023
***************************************************************************************************************
--%>
<%@ Page Language="VB"   StylesheetTheme="white" Debug="true" %>

<%@ Register Src="menu.ascx" TagName="menu" TagPrefix="uc1" %>
<%@ Register Assembly="BusyBoxDotNet" Namespace="BusyBoxDotNet" TagPrefix="busyboxdotnet" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ import Namespace="System.Web.Mail" %>

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
        
        If region = "UIO" Then
            region = "R1"
        Else
            region = "R2"
        End If
        
        ds_guardar.InsertParameters.Item("region").DefaultValue = region
        
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
               
       
        '*****************************************************     
       
        If Tipo.SelectedValue = "P" Then
          
               
            'Dim conn2 As SqlConnection = New SqlConnection(ConfigurationManager.ConnectionStrings("CRMConnectionString").ConnectionString)
      
            'Dim cmd2 As SqlCommand = New SqlCommand()
            'cmd2.Connection = conn2
            'Dim cmd3 As SqlCommand = New SqlCommand()
            'cmd3.Connection = conn2
            'Dim cmd4 As SqlCommand = New SqlCommand()
            'cmd4.Connection = conn2
                          
            'Dim codig As TextBox = New TextBox
            'Dim c_req As TextBox = New TextBox
            'Dim n_tram As TextBox = New TextBox
            'c_req.Text = 25
            'n_tram.Text = "-"
            'Dim re As SqlDataReader = conexion.traerDataReader("select top 1 codigo from tbl_pymes_clientes where ced_ruc='" & ced_ruc.Text & "' and estado='A' order by codigo desc", 3)
          
            'While re.Read
            '    codig.Text = re.GetValue(0)
            'End While
        
            
            'If codig.Text > "0" Then
            '    Dim est As New TextBox
            '    est.Text = "1"
             
            '    cmd2.CommandText = " insert into tbl_pymes_bitacora_clientes_servicio (cod_padre,cod_req,num_tramite,usuario,observacion,cod_sim,estado) values (" & codig.Text & "," & c_req.Text & ",'" & n_tram.Text & "','" & usuario.Value & "','" & obs.Text & "'," & cod_sim.Text & ",'" & est.Text & "')"
            '    Dim id As TextBox = New TextBox
            '    Dim tipo As TextBox = New TextBox
            '    tipo.Text = "S"
           
            '    Dim re2 As SqlDataReader = conexion.traerDataReader("select top 1 codigo from tbl_pymes_bitacora_clientes_servicio order by codigo desc ", 3)
            '    While re2.Read
            '        id.Text = re2.GetValue(0) + 1
            '    End While
                        
            '    cmd3.CommandText = "insert into Tbl_pymes_tramites_general (tipo,cod_gen,cod_padre) values ('" & tipo.Text & "','" & id.Text & "'," & codig.Text & ")"


            '    Dim cod_gen As New TextBox
               
            '    Dim re3 As SqlDataReader = conexion.traerDataReader("select top 1 id from Tbl_pymes_tramites_general order by id desc ", 3)
            '    While re3.Read
            '        cod_gen.Text = re3.GetValue(0) + 1
            '    End While
            '    cmd4.CommandText = "insert into Tbl_pymes_estados_tramite (cod_tramite,estado,usuario,tipo,cod_sim,observacion) values  ('" & cod_gen.Text & "','" & est.Text & "','" & usuario.Value & "','" & tipo.Text & "','" & cod_sim.Text & "','" & obs.Text & "')"
            '    re2.Close()
            '    re3.Close()
           
            'End If
                
            'Dim rowCount2 As Integer
            'Dim previousConnectionState2 As ConnectionState
            'previousConnectionState2 = conn2.State
            'Try
            '    If conn2.State = ConnectionState.Closed Then
            '        conn2.Open()
            '    End If
          
            '    rowCount2 = cmd2.ExecuteNonQuery()
            '    rowCount2 = cmd3.ExecuteNonQuery()
            '    rowCount2 = cmd4.ExecuteNonQuery()
            'Finally
               
            '    If previousConnectionState2 = ConnectionState.Closed Then
            '        conn2.Close()
            '    End If
            'End Try
            're.Close()
      
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
        cmd5.Parameters.AddWithValue("ciudad", ddl_ciudad.SelectedValue.ToString())
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
		
		'22735 - Reposicion SIMCARD corporativo - actualiza solicitud a pendiente
		Dim estadoP as String = "X"
		ds_actualizar_sol.UpdateParameters.Item("estado").DefaultValue = estadoP
		ds_actualizar_sol.UpdateParameters.Item("id_padre_sim").DefaultValue = cod_sim.Text
		ds_actualizar_sol.Update()
		
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


    Protected Sub ddl_ciudad_SelectedIndexChanged(sender As Object, e As System.EventArgs)
        If celular.Text = "" Then
            celular.Text = "0"
        End If
    End Sub


    Protected Sub btn_Det_Cancelar_Click(sender As Object, e As System.EventArgs)
        valida.Visible = False
        txt_Det_NumRep.Text = ""
        ddl_Det_MotRep.Items.Clear()
        ddl_Det_MotRep.Items.Add("-Seleccionar-")
        ddl_Det_MotRep.Items.Add("Robo")
        ddl_Det_MotRep.Items.Add("Daño/Perdida")
		ddl_Det_MotRep.Items.Add("Stock de simcard")
        ddl_Det_MotRep.Items.FindByText("-Seleccionar-").Value = "-1"
        ddl_Det_MotRep.Items.FindByText("Robo").Value = "R"
        ddl_Det_MotRep.Items.FindByText("Daño/Perdida").Value = "A"
		ddl_Det_MotRep.Items.FindByText("Stock de simcard").Value = "S"
        ddl_Det_MotRep.Items.FindByText("-Seleccionar-").Selected = True
        
        ddl_Det_TipChip.Items.Clear()
        ddl_Det_TipChip.Items.Add("-Seleccionar-")
        ddl_Det_TipChip.Items.Add("Simcard Normal")
        ddl_Det_TipChip.Items.Add("Mini Simcard")
        ddl_Det_TipChip.Items.Add("Nano Simcard")
        ddl_Det_TipChip.Items.FindByText("-Seleccionar-").Value = "-1"
        ddl_Det_TipChip.Items.FindByText("Simcard Normal").Value = "C"
        ddl_Det_TipChip.Items.FindByText("Mini Simcard").Value = "M"
        ddl_Det_TipChip.Items.FindByText("Nano Simcard").Value = "N"
        ddl_Det_TipChip.Items.FindByText("-Seleccionar-").Selected = True
    End Sub


    Protected Sub btn_Registrar_Detalle_Click(sender As Object, e As System.EventArgs)
        Dim contador As Integer = Convert.ToInt32(celular.Text.ToString())
        
        valida.Visible = False
        
        If (txt_Det_NumRep.Text <> "" And ddl_Det_MotRep.Items.FindByText("-Seleccionar-").Selected = False And ddl_Det_TipChip.Items.FindByText("-Seleccionar-").Selected = False) Then
            If contador < 10 Then
                
                If Tipo.SelectedValue = "P" Then
                    Dim re As SqlDataReader = conexion.traerDataReader("select top 1 codigo from tbl_pymes_clientes where ced_ruc='" & ced_ruc.Text & "' and estado='A' order by codigo desc", 3)
                    If re.HasRows Then
                        ds_con_det.InsertParameters.Item("usuario_Registro").DefaultValue = User.Identity.Name
                        ds_con_det.Insert()
                        ds_con_det.DataBind()
                        contador = contador + 1
                        celular.Text = contador.ToString()
                        valida.Text = ""
                        valida.Visible = False
                        txt_Det_NumRep.Text = ""
                        ddl_Det_MotRep.Items.Clear()
                        ddl_Det_MotRep.Items.Add("-Seleccionar-")
                        ddl_Det_MotRep.Items.Add("Robo")
                        ddl_Det_MotRep.Items.Add("Daño/Perdida")
						ddl_Det_MotRep.Items.Add("Stock de simcard")
                        ddl_Det_MotRep.Items.FindByText("-Seleccionar-").Value = "-1"
                        ddl_Det_MotRep.Items.FindByText("Robo").Value = "R"
                        ddl_Det_MotRep.Items.FindByText("Daño/Perdida").Value = "A"
						ddl_Det_MotRep.Items.FindByText("Stock de simcard").Value = "S"
                        ddl_Det_MotRep.Items.FindByText("-Seleccionar-").Selected = True
        
                        ddl_Det_TipChip.Items.Clear()
                        ddl_Det_TipChip.Items.Add("-Seleccionar-")
                        ddl_Det_TipChip.Items.Add("Simcard Normal")
                        ddl_Det_TipChip.Items.Add("Mini Simcard")
                        ddl_Det_TipChip.Items.Add("Nano Simcard")
                        ddl_Det_TipChip.Items.FindByText("-Seleccionar-").Value = "-1"
                        ddl_Det_TipChip.Items.FindByText("Simcard Normal").Value = "C"
                        ddl_Det_TipChip.Items.FindByText("Mini Simcard").Value = "M"
                        ddl_Det_TipChip.Items.FindByText("Nano Simcard").Value = "N"
                        ddl_Det_TipChip.Items.FindByText("-Seleccionar-").Selected = True
                    Else
                        valida.Visible = True
                        valida.Text = "La cuenta NO pertenece a ningun cliente Corporativo."
                    End If
                Else
                    ds_con_det.InsertParameters.Item("usuario_Registro").DefaultValue = User.Identity.Name
                    ds_con_det.Insert()
                    ds_con_det.DataBind()
                    contador = contador + 1
                    celular.Text = contador.ToString()
                    valida.Text = ""
                    valida.Visible = False
                    txt_Det_NumRep.Text = ""
                    ddl_Det_MotRep.Items.Clear()
                    ddl_Det_MotRep.Items.Add("-Seleccionar-")
                    ddl_Det_MotRep.Items.Add("Robo")
                    ddl_Det_MotRep.Items.Add("Daño/Perdida")
					ddl_Det_MotRep.Items.Add("Stock de simcard")
                    ddl_Det_MotRep.Items.FindByText("-Seleccionar-").Value = "-1"
                    ddl_Det_MotRep.Items.FindByText("Robo").Value = "R"
                    ddl_Det_MotRep.Items.FindByText("Daño/Perdida").Value = "A"
					ddl_Det_MotRep.Items.FindByText("Stock de simcard").Value = "S"
                    ddl_Det_MotRep.Items.FindByText("-Seleccionar-").Selected = True
        
                    ddl_Det_TipChip.Items.Clear()
                    ddl_Det_TipChip.Items.Add("-Seleccionar-")
                    ddl_Det_TipChip.Items.Add("Simcard Normal")
                    ddl_Det_TipChip.Items.Add("Mini Simcard")
                    ddl_Det_TipChip.Items.Add("Nano Simcard")
                    ddl_Det_TipChip.Items.FindByText("-Seleccionar-").Value = "-1"
                    ddl_Det_TipChip.Items.FindByText("Simcard Normal").Value = "C"
                    ddl_Det_TipChip.Items.FindByText("Mini Simcard").Value = "M"
                    ddl_Det_TipChip.Items.FindByText("Nano Simcard").Value = "N"
                    ddl_Det_TipChip.Items.FindByText("-Seleccionar-").Selected = True
                End If
            Else
                valida.Text = "El maximo numero de lineas que puede ingresar es de 10."
                valida.Visible = True
            End If
        Else
            valida.Text = "Debe ingresar numero, motivo y tipo de chip para añadir una linea a la solicitud de reposición."
            valida.Visible = True
        End If
    End Sub


    Protected Sub gv_lineas_solicitud_RowDeleting(sender As Object, e As System.Web.UI.WebControls.GridViewDeleteEventArgs)


    End Sub


    Protected Sub gv_lineas_solicitud_RowDeleted(sender As Object, e As System.Web.UI.WebControls.GridViewDeletedEventArgs)
        Dim contador As Integer = Convert.ToInt32(celular.Text.ToString())
        contador = contador - 1
        celular.Text = contador.ToString()
    End Sub
    
</script>




    
<script language =javascript >


function validar_nom(source,arguments) { 
	
if ((arguments.Value.length==0)){
    alert("Por favor, indique el nombre del cliente.");
	arguments.IsValid=false;}
	else
	arguments.IsValid=true;


}	


function validar_nom_c(source,arguments) { 
	
if ((arguments.Value.length==0)){
    alert("Por favor, indique el nombre de contacto.");
	arguments.IsValid=false;}
	else
	arguments.IsValid=true;


}	
function validar_ases(source,arguments) { 
	
if (arguments.Value=="-"){
    alert("Por favor, escoja el Asesor Empresarial solicitante.");
	arguments.IsValid=false;}
	else
	arguments.IsValid=true;


}


function validar_dir(source,arguments) { 
	
if ((arguments.Value.length==0)){
    alert("Por favor, indique la dirección completa de entrega.");
	arguments.IsValid=false;}
	else
	arguments.IsValid=true;


}	


function validar_coment(source,arguments) { 
	
if ((arguments.Value.length==0)){
    alert("Por favor, especifique algun comentario adicional respecto al caso.");
	arguments.IsValid=false;}
	else
	arguments.IsValid=true;


}


function validar_cta(source,arguments) { 
	
if ((arguments.Value.length<6)){
    alert("Por favor, indique el número de cuenta.");
	arguments.IsValid=false;}
	else
	arguments.IsValid=true;


}


function validar_telf_c(source,arguments) { 
	
if ((arguments.Value.length<9)){
    alert("Por favor, indique el teléfono de contacto.");
	arguments.IsValid=false;}
	else
	arguments.IsValid=true;


}


function validar_telf_c2(source,arguments) { 
	
if ((arguments.Value.length<9)){
    alert("Por favor, indique el teléfono de contacto.");
	arguments.IsValid=false;}
	else
	arguments.IsValid=true;


}	


function validar_num(source,arguments) { 
	
if ((arguments.Value.length<9)){
    alert("Por favor, ingrese el número celular completo.");
	arguments.IsValid=false;}
	else
	arguments.IsValid=true;


}
//8957 - INICIO CIM GORTIZ
function validar_region(source, arguments)
{
    //Se valida la seleccion de la región del cliente
    if (arguments.Value == "-1")
    {
        alert("Por favor, seleccione la región del cliente.");
        arguments.IsValid = false;
    }
    else
        arguments.IsValid = true;
}
function validar_ciudad(source, arguments) {
    //Se valida la seleccion de la ciudad del cliente
    if (arguments.Value == "-1")
    {
        alert("Por favor, seleccione la ciudad del cliente.");
        arguments.IsValid = false;
    }
    else
        arguments.IsValid = true;
}
function validar_correo(source, arguments) {
    //Se valida el ingreso del correo del cliente
    if (arguments.Value == "")
    {
        alert("Por favor, ingrese el correo del cliente.");
        arguments.IsValid = false;
    }
    else
        arguments.IsValid = true;
}
function validar_telf_adm(source,arguments)
{ 
    //Se valida el ingreso de los 10 numeros del telefono administrador	
    if ((arguments.Value.length < 10))
    {
        alert("Por favor, ingrese los 10 digitos del telefono administrador.");
	    arguments.IsValid=false;
    }
	else
	    arguments.IsValid=true;
}
//8957 - FIN CIM GORTIZ
</script>


<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">


    <title>Reposici&#243;n de Simcard | Ingreso</title> 
      <script language="javascript" src="/portalsco/include/js/calendar/popcalendar.js"></script>
    <LINK href="/portalsco/include/js/calendar/popcalendar.css" type="text/css" rel="stylesheet"> 
    <style type="text/css">
        .style2
        {
            height: 68px;
        }
        .style3
        {
            height: 14px;
        }
        .style4
        {
            height: 38px;
        }
        .style5
        {
            height: 22px;
        }
        .style6
        {
            color: #000000;
        }
    </style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" >
    <form id="form1" runat="server">
        <strong><span style="color: #ff0000">
            <table cellpadding="0" cellspacing="0" style="height: 88px" width="100%">
                <tbody>
                    <tr>
                        <td background="../../../images/apl/simcard.jpg">
                        </td>
                    </tr>
                </tbody>
            </table>
            <uc1:menu ID="Menu1" runat="server" />
           </strong>
    <asp:Panel ID="Panel1" runat="server" Width="100%" SkinID="porta" HorizontalAlign="Center" >
        <br />
        <br />
        <br />
         
                    <table style="width: 800px" align="center">
                        <tr>
                            <td>
                                <strong><span style="color: #000000">
                                Fecha:</span></strong></td>
                            <td><%=FormatDateTime(Date.Now,DateFormat.LongDate)%>
                            </td>
                            <td>
                                <strong><span style="color: #000000">
                                </span></strong></td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <strong><span style="color: #000000">
                                Login:</span></strong></td>
                            <td>
                            <asp:Label ID="Label4" runat="server" Text="Label" Font-Bold="False" ForeColor="DimGray"></asp:Label></td>
                            <td>
                            </td>
                            <td>
                            </td>
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
                            <td >
                                <strong><span style="color: #000000">
                                    <asp:Label ID="asesor" runat="server" Text="Asesor Empresarial:"></asp:Label></span></strong></td>
                            <td>
                                <asp:DropDownList ID="ases" runat="server" AppendDataBoundItems="True" DataSourceID="ds_ases"
                                    DataTextField="usuario" DataValueField="username">
                                    <asp:ListItem Selected="True" Value="-">-Seleccione Asesor-</asp:ListItem>
                                </asp:DropDownList>
                                <asp:CustomValidator ID="CustomValidator1" runat="server" ClientValidationFunction="validar_ases"
                                    ControlToValidate="ases" ErrorMessage="*" SetFocusOnError="True" ValidateEmptyText="True"></asp:CustomValidator></td>
                            <td>
                                <strong><span style="color: #000000">
                                Cuenta Axis:</span></strong></td>
                            <td>
                                <asp:TextBox ID="cta_axis" runat="server" MaxLength="10" onkeypress="if ((event.keyCode > 0 && event.keyCode < 46)|| (event.keyCode == 47)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="81px"></asp:TextBox>
                                </td>
                        </tr>
                        <tr>
                            <td>
                                <strong><span style="color: #000000">
                                
                                Nombre del Cliente:</span></strong></td>
                            <td >
                                <asp:TextBox ID="nombre" runat="server" MaxLength="60" Width="249px"></asp:TextBox>
                                <asp:CustomValidator ID="CustomValidator4" runat="server" ClientValidationFunction="validar_nom"
                                    ControlToValidate="nombre" ErrorMessage="*" SetFocusOnError="True" ValidateEmptyText="True"></asp:CustomValidator></td>
                            <%--8957 - REGION DEL CLIENTE--%>
                            <td>
                                <strong><span style="color: #000000">
                                Region del Cliente:</span></strong></td>
                            <td>
                                <span style="color: #ff0000">
                                <asp:DropDownList ID="ddl_region" runat="server" AppendDataBoundItems="True" 
                                    AutoPostBack="True" onselectedindexchanged="ddl_region_SelectedIndexChanged">
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
                            <td class="style2">
                                <strong><span style="color: #000000">
                                Dirección de Entrega:</span></strong></td>
                            <td class="style2">
                                <asp:TextBox ID="dir" runat="server" Columns="14" MaxLength="200" onkeypress="if ((event.keyCode > 0 && event.keyCode < 32)|| (event.keyCode > 33 && event.keyCode < 35) ||(event.keyCode > 38 && event.keyCode < 40) ||(event.keyCode > 95 && event.keyCode < 97) ||(event.keyCode > 125 && event.keyCode < 129) || (event.keyCode > 165 && event.keyCode < 256)) event.returnValue = false;"
                                    Rows="5" TextMode="MultiLine" Width="264px"></asp:TextBox>
                                <asp:CustomValidator ID="CustomValidator3" runat="server" ClientValidationFunction="validar_dir"
                                    ControlToValidate="dir" ErrorMessage="*" SetFocusOnError="True" ValidateEmptyText="True"></asp:CustomValidator></td>
                            <td>
                                <strong><span style="color: #000000">
                                
                                Ciudad:</span></strong></td>
                            <td >
                            <%--8957-CIUDAD DEL CLIENTE--%>
                                <span style="color: #ff0000">
                                <asp:DropDownList ID="ddl_ciudad" runat="server" AppendDataBoundItems="True" 
                                    DataSourceID="ds_ciudad" DataTextField="Nombre" DataValueField="Id" 
                                    onselectedindexchanged="ddl_ciudad_SelectedIndexChanged" 
                                    AutoPostBack="True">
                                </asp:DropDownList>
                                <asp:CustomValidator ID="cv_CiudadCliente" runat="server" 
                                    ClientValidationFunction="validar_ciudad" ControlToValidate="ddl_ciudad" 
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
                                    Rows="5" TextMode="MultiLine" Visible="False" Width="115px"></asp:TextBox>
                                <asp:TextBox ID="celular" runat="server" MaxLength="9" 
                                    onkeypress="if ((event.keyCode &gt; 0 &amp;&amp; event.keyCode &lt; 48)|| (event.keyCode &gt; 57 &amp;&amp; event.keyCode &lt; 256)) event.returnValue = false;" 
                                    Visible="False" Width="68px" AutoPostBack="True"></asp:TextBox>
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
                                    Width="100px"></asp:TextBox>
                                <asp:CustomValidator ID="cv_TelfAdministrador" runat="server" 
                                    ClientValidationFunction="validar_telf_adm" ControlToValidate="txt_TelfAdministrador" 
                                    ErrorMessage="*" SetFocusOnError="True" ValidateEmptyText="True">
                                </asp:CustomValidator>
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <td class="style5">
                                <strong><span style="color: #000000">
                                Persona de Contacto:</span></strong></td>
                            <td class="style5" >
                                <asp:TextBox ID="nom_contacto" runat="server" MaxLength="50" Width="249px"></asp:TextBox>
                                <asp:CustomValidator ID="CustomValidator6" runat="server" ClientValidationFunction="validar_nom_c"
                                    ControlToValidate="nom_contacto" ErrorMessage="*" SetFocusOnError="True" ValidateEmptyText="True"></asp:CustomValidator></td>
                            <td class="style5">
                                <strong><span style="color: #000000">
                                Telf. de Contacto 1:</span></strong></td>
                            <td class="style5">
                                <asp:TextBox ID="telf_contacto" runat="server" MaxLength="10" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="100px"></asp:TextBox>
                                <asp:CustomValidator ID="CustomValidator7" runat="server" ClientValidationFunction="validar_telf_c"
                                    ControlToValidate="telf_contacto" ErrorMessage="*" SetFocusOnError="True" ValidateEmptyText="True"></asp:CustomValidator></td>
                        </tr>
                        <tr>
                            <%--8957-CORREO DEL CLIENTE--%>
                            <td class="style9">
                                <strong><span style="color: #000000">
                                Correo del Cliente:</span></strong></td>
                            <td style="height: 22px">
                                <span style="color: #000000">
                                <asp:TextBox ID="txt_CorreoCliente" runat="server" MaxLength="60" Width="249px">
                                </asp:TextBox>
                                <asp:CustomValidator ID="cv_CorreoCliente" runat="server" 
                                    ClientValidationFunction="validar_correo" ControlToValidate="txt_CorreoCliente" 
                                    ErrorMessage="*" SetFocusOnError="True" ValidateEmptyText="True">
                                </asp:CustomValidator>
                                </span>
                            </td>
                            <td style="height: 22px">
                                <strong><span style="color: #000000">
                                Telf. de Contacto 2:</span></strong></td>
                            <td style="height: 22px">
                                <asp:TextBox ID="contacto2" runat="server" MaxLength="10" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="100px"></asp:TextBox>
                                <asp:CustomValidator ID="CustomValidator8" runat="server" ClientValidationFunction="validar_telf_c2"
                                    ControlToValidate="contacto2" ErrorMessage="*" SetFocusOnError="True" ValidateEmptyText="True"></asp:CustomValidator></td>
                        </tr>
                    </table>
        <span style="color: #ff0000">
            <br />
        </span>
        <asp:Label ID="valida" runat="server" Font-Bold="True" Font-Size="10pt"></asp:Label><br />
            <br />
        <strong><span style="color: #000000">
            Observaciones:</span><br />
        </strong>
                    <asp:TextBox ID="observacion" runat="server" MaxLength="500" 
            Rows="6" TextMode="MultiLine"
                        Width="380px" Height="54px"></asp:TextBox>
        <br />
        <asp:CustomValidator ID="CustomValidator5" runat="server" ClientValidationFunction="validar_coment"
            ControlToValidate="observacion" SetFocusOnError="True" ValidateEmptyText="True"></asp:CustomValidator><br />
                    <br />
        <%--CIM GORTIZ - PANEL INGRESO DETALLE DE LINEAS MINIMO 1 MAXIMO 10--%>
        <asp:Panel ID="pnl_DetalleSolicitud" runat="server">
            <br />
            <table align="center" border="0" 
                style="border: thin ridge #FF0000; width: 27%;">
                <tr>
                    <td class="style3" colspan="5" align="center" bgcolor="#CC0000" 
                        style="color: #FFFFFF">
                        Detalle de la solicitud</td>
                </tr>
                <tr align="center">
                    <td class="style10" align="center" bgcolor="#CCCCCC">
                        <asp:Label ID="lbl_Det_NumRep" runat="server" Text="Número de reposición"></asp:Label>
                    </td>
                    <td class="style12" align="center" bgcolor="#CCCCCC">
                        <asp:Label ID="lbl_Det_MotRep" runat="server" Text="Motivo de la reposición"></asp:Label>
                    </td>
                    <td class="style13" align="center" bgcolor="#CCCCCC">
                        <asp:Label ID="lbl_Det_TipRep" runat="server" Text="Tipo de chip"></asp:Label>
                    </td>
                    <td class="style14" align="center" bgcolor="#CCCCCC">
                    </td>
                    <td class="style14" align="center" bgcolor="#CCCCCC">
                    </td>
                </tr>
                <tr>
                        <td class="style3">
                            <asp:TextBox ID="txt_Det_NumRep" runat="server" Height="19px" Width="91px"></asp:TextBox>
                        </td>
                        <td class="style15">
                            <span style="color: #ff0000">
							<%--RAR 20161207 se agrega nueva opci??n llamada stock de simcard--%>
                            <asp:DropDownList ID="ddl_Det_MotRep" runat="server" AppendDataBoundItems="True" 
                                DataTextField="motivo_nom" DataValueField="motivo_id">
                                <asp:ListItem Selected="True" Value="-1">-Seleccionar-</asp:ListItem>
                                <asp:ListItem Value="R">Robo</asp:ListItem>
                                <asp:ListItem Value="A">Daño/Perdida</asp:ListItem>
								<asp:ListItem Value="S">Stock de simcard</asp:ListItem>
                            </asp:DropDownList>
                            </span>
                        </td>
                        <td class="style16">
                            <span style="color: #ff0000">
                            <asp:DropDownList ID="ddl_Det_TipChip" runat="server" AppendDataBoundItems="True" 
                                DataTextField="tipoChip_nom" DataValueField="tipoChip_id">
                                <asp:ListItem Selected="True" Value="-1">-Seleccionar-</asp:ListItem>
                                <asp:ListItem Value="C">Simcard Normal</asp:ListItem>
                                <asp:ListItem Value="M">Mini Simcard</asp:ListItem>
                                <asp:ListItem Value="N">Nano Simcard</asp:ListItem>
                            </asp:DropDownList>
                            </span>
                        </td>
                        <td class="style17" align="center">
                            <asp:Button ID="btn_Registrar_Detalle" runat="server" Text="Agregar" 
                                onclick="btn_Registrar_Detalle_Click" Font-Bold="True" />
                        </td>
                        <td class="style17" align="center">
                            <asp:Button ID="btn_Det_Cancelar" runat="server" Text="Cancelar" 
                                Font-Bold="True" onclick="btn_Det_Cancelar_Click" />
                        </td>
                </tr>
                <tr align="center">
                    <td align="center" bgcolor="White" class="style10" colspan="5">
                        <strong><span style="color: #ff0000">
                        <br />
                        <asp:GridView ID="gv_lineas_solicitud" runat="server" 
                            AutoGenerateColumns="False" DataKeyNames="id_sim_det" 
                            DataSourceID="ds_con_det" SkinID="porta" Width="100%" 
                            EnableModelValidation="True" 
                            AutoGenerateDeleteButton="True" 
                            onrowdeleting="gv_lineas_solicitud_RowDeleting" 
                            onrowdeleted="gv_lineas_solicitud_RowDeleted">
                            <EmptyDataTemplate>
                                No hay lineas ingresadas
                            </EmptyDataTemplate>
                            <Columns>
                                <asp:TemplateField HeaderText="Id detalle" SortExpression="id_sim_det" 
                                    Visible="False">
                                    <ItemTemplate>
                                        <asp:Label ID="lbl_id_sim_det" runat="server" Text='<%# Bind("id_sim_det") %>'></asp:Label>
                                        <br />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                                    <EditItemTemplate>
                                    </EditItemTemplate>
                                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" 
                                        VerticalAlign="Middle" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Número" SortExpression="num_rep_det">
                                    <ItemTemplate>
                                        <asp:Label ID="lbl_num_rep_det" runat="server" 
                                            Text='<%# Bind("telefono_Reposicion") %>'></asp:Label>
                                        <br />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                                    <EditItemTemplate>
                                    </EditItemTemplate>
                                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" 
                                        VerticalAlign="Middle" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Motivo" SortExpression="mot_rep_det">
                                    <ItemTemplate>
                                        <asp:Label ID="lbl_mot_rep_det" runat="server" 
                                            Text='<%# Bind("motivo_Reposicion") %>'></asp:Label>
                                        <br />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                                    <EditItemTemplate>
                                    </EditItemTemplate>
                                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" 
                                        VerticalAlign="Middle" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Tipo" SortExpression="tip_rep_det">
                                    <ItemTemplate>
                                        <asp:Label ID="lbl_tip_rep_det" runat="server" 
                                            Text='<%# Bind("tipochip_Reposicion") %>'></asp:Label>
                                        <br />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                                    <EditItemTemplate>
                                    </EditItemTemplate>
                                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" 
                                        VerticalAlign="Middle" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Fecha" SortExpression="fecha_reg">
                                    <ItemTemplate>
                                        <asp:Label ID="lbl_fecha_registro_det" runat="server" 
                                            Text='<%# Bind("fecha_registro") %>'></asp:Label>
                                        <br />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                                    <EditItemTemplate>
                                    </EditItemTemplate>
                                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" 
                                        VerticalAlign="Middle" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        </span></strong>
                    </td>
                </tr>
            </table>
        </asp:Panel>
        <br />
        <br />
                    <asp:Button ID="grabar" runat="server" Text="Grabar" OnClick="guardar_click" Font-Bold="True" ForeColor="#000000" /><br />
        <br />
        <br />
    </asp:Panel>&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
        <asp:SqlDataSource ID="ds_guardar" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
            InsertCommand="INSERT INTO Tbl_atv_reposicion_sim
(fecha_ing, nom_ases, nom_cliente, cta_axis, direccion, nom_contacto, telf_contacto, num_repo, login, ip, observacion, num_repo_v, telf_contacto2,tipo, region_cliente, correo_cliente)
VALUES
(GETDATE(), @nom_ases, @nom_cliente, @cta_axis, @direccion, @nom_contacto, @telf_contacto, '0'+@num_repo, @login, @ip, @observacion, '-'+@num_repo_v, @telf_contacto2,@tipo, @region, @correo)
; select @return_id=scope_identity()" OnInserted="ds_guardar_Inserted" >
            <InsertParameters>
                <asp:ControlParameter ControlID="ases" Name="nom_ases" PropertyName="SelectedValue" />
                <asp:ControlParameter ControlID="nombre" Name="nom_cliente" PropertyName="Text" />
                <asp:ControlParameter ControlID="cta_axis" Name="cta_axis" PropertyName="Text" />
                <asp:ControlParameter ControlID="dir" Name="direccion" PropertyName="Text" />
                <asp:ControlParameter ControlID="nom_contacto" Name="nom_contacto" PropertyName="Text" />
                <asp:ControlParameter ControlID="telf_contacto" Name="telf_contacto" PropertyName="Text" />
                <asp:ControlParameter ControlID="contacto2" Name="telf_contacto2" PropertyName="Text" />
                <asp:ControlParameter ControlID="celular" Name="num_repo" PropertyName="Text" />
                <asp:ControlParameter ControlID="num_repo_v" Name="num_repo_v" PropertyName="Text" />
                <asp:ControlParameter ControlID="usuario" Name="login" PropertyName="Value" />
                <asp:ControlParameter ControlID="ip" Name="ip" PropertyName="Value" />
                <asp:ControlParameter ControlID="observacion" Name="observacion" PropertyName="Text" />
                <asp:Parameter Name="return_id" Type="Int32" Direction="InputOutput" />
                <asp:ControlParameter ControlID="Tipo" Name="tipo" PropertyName="SelectedValue" />
                <asp:Parameter Name="region" />
                <asp:ControlParameter ControlID="txt_CorreoCliente" Name="correo" 
                    PropertyName="Text" />
            </InsertParameters>
        </asp:SqlDataSource>
        <busyboxdotnet:BusyBox ID="BusyBox1" runat="server" SlideDuration="900" Text="Por favor espere mientras se procesan los datos." Title="Portal SCO" />
        <asp:SqlDataSource ID="grab_pymes" runat="server" ConnectionString="<%$ ConnectionStrings:CRMConnectionString %>"
            SelectCommand="s"></asp:SqlDataSource>
        <asp:SqlDataSource ID="ds_ases" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
            SelectCommand="select username, E.nombre+' '+E.apellido as usuario&#13;&#10;from aspnet_users A&#13;&#10;inner join aspnet_usersinroles B on A.userid=B.userid&#13;&#10;inner join aspnet_roles C on B.roleid=C.roleid&#13;&#10;inner join aspnet_membership D on A.userid=D.userid&#13;&#10;inner join aspnet_perfiles E on A.userid=E.userid&#13;&#10;where c.rolename='P COM Ases' and D.isapproved='1'&#13;&#10;order by e.nombre, e.apellido">
        </asp:SqlDataSource>
        &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
        &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
        &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
        &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
        <asp:HiddenField ID="usuario" runat="server" />
        <asp:HiddenField ID="ip" runat="server" />
        <asp:HiddenField ID="mail" runat="server" />
        <%--DATA SOURCE PARA LA CIUDAD--%>
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
        <%--DATA SOURCE PARA DETALLE DE SOLICITUD--%>
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
		<%--22735 - DATASOURCE ACTUALIZAR SOLICITUD A PENDINETE--%>
        <asp:SqlDataSource ID="ds_actualizar_sol" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
            UpdateCommand="UPDATE Tbl_atv_reposicion_sim_proceso SET ultimo_estado = @estado WHERE id_padre = @id_padre_sim">
            <UpdateParameters>
                <asp:Parameter Name="estado" />
                <asp:Parameter Name="id_padre_sim" />
            </UpdateParameters>
        </asp:SqlDataSource>
</form>
</body>
</html>
