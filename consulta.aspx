<%--
***************************************************************************************************************
DESCRIPCION: Formulario de consulta reposicion Simcard
CREADOR: Paul Cobos 
FECHA DE ACTUALIZACIÓN: 24/01/2008
MODIFICADO POR: SIS RAR 
MOTIVO DE MODIFICACIÓN: cambios para nuevo personal de tramites VIP R1/R2
FECHA DE MODIFICACIÓN: 03/07/2012
***************************************************************************************************************
***************************************************************************************************************
DESCRIPCION: Formulario de consulta reposicion Simcard
MODIFICADO POR: Cima-Manuel Marín S. 
MOTIVO DE MODIFICACIÓN: Envio del usuario al formulario de detalle.aspx (Session("USER"))
FECHA DE MODIFICACIÓN: 20/05/2014
***************************************************************************************************************
***************************************************************************************************************
DESCRIPCION: Formulario de consulta reposicion Simcard
MODIFICADO POR: Cima Galo Ortiz C. 
MOTIVO DE MODIFICACIÓN: Se modifica consulta del data source DS CON para poder realizar busquedas de tramites por
                        el criterio numero de reposicion de simcard.
FECHA DE MODIFICACIÓN: 30/06/2014
***************************************************************************************************************
***************************************************************************************************************
DESCRIPCION: [22735] - Reposicion SIMCARD corporativo
MODIFICADO POR: SUD. GVillanueva
MOTIVO DE MODIFICACIÓN: Boton cancelar para cancelar solicitudes pendientes (X) - Resolución ARCOTEL-2022-0335, articulo 18.1
FECHA DE MODIFICACIÓN: 14/07/2023
***************************************************************************************************************
--%>
<%@ Page Language="VB" StylesheetTheme="White"%>


<%@ Register Src="menu.ascx" TagName="menu" TagPrefix="uc1" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OracleClient" %>
<%@ Import Namespace="System.Data.OracleClient.OracleConnection" %>
<%@ import Namespace="System.Web.Mail" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">


<script runat="server">    
    Public conection As conexiones = New conexiones()
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If User.Identity.IsAuthenticated Then
            Label4.Text = Profile.Nombre & "  " & Profile.Apellido & " " & "[" & User.Identity.Name & "]"
            Session("USER") = User.Identity.Name
        End If
         
        If Not Page.IsPostBack Then
            fecha_i.Text = "01/" & Month(Now()) & "/" & Year(Now())
            fecha_f.Text = Day(Now()) & "/" & Month(Now()) & "/" & Year(Now())
        End If
        
        If User.IsInRole("Apl Reposicion Sim R1") And Me.txt_control_region.Text <> "R" Then


            If Me.cmb_id_region.SelectedValue = "-1" Then
                cmb_id_region.Items.Clear()
                cmb_id_region.Items.Add("-Todos-")
                cmb_id_region.Items.Add("R1 - UIO")
                cmb_id_region.Items.Add("R2 - GYE")
                cmb_id_region.Items.FindByText("-Todos-").Value = "-1"
                cmb_id_region.Items.FindByText("R1 - UIO").Value = "R1"
                cmb_id_region.Items.FindByText("R2 - GYE").Value = "R2"
                cmb_id_region.Items.FindByText("R1 - UIO").Selected = True
                Me.txt_control_region.Text = "R"
            End If
        Else
            If User.IsInRole("Apl Reposicion Sim R2") And Me.txt_control_region.Text <> "R" Then
                If Me.cmb_id_region.SelectedValue = "-1" Then
                    cmb_id_region.Items.Clear()
                    cmb_id_region.Items.Add("-Todos-")
                    cmb_id_region.Items.Add("R1 - UIO")
                    cmb_id_region.Items.Add("R2 - GYE")
                    cmb_id_region.Items.FindByText("-Todos-").Value = "-1"
                    cmb_id_region.Items.FindByText("R1 - UIO").Value = "R1"
                    cmb_id_region.Items.FindByText("R2 - GYE").Value = "R2"
                    cmb_id_region.Items.FindByText("R2 - GYE").Selected = True
                    Me.txt_control_region.Text = "R"
                End If
            End If
            ds_con.DataBind()
        End If
        
    End Sub


    Protected Sub Btn_consultar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        GridView1.DataBind()
    End Sub


   Protected Sub LinkButton1_Click(ByVal sender As Object, ByVal e As System.EventArgs)
      
        If nom.Text = "" Then
            nom.Text = "aaa"
        End If
        
        
        If tram.Text = "" Then
            tram.Text = "000"
        End If
        
        If axis.Text = "" Then
            axis.Text = "999"
        End If
        
        
        Dim queryString As String = ""
        queryString = " con_reptexto_simcard '" & fecha_i.Text & "','" & fecha_f.Text & "','" & nom.Text & "','" & tram.Text & "','" & axis.Text & "','" & login.SelectedValue & "','" & estado.SelectedValue & "','" & ases.SelectedValue & "','" & num_repo.Text & "','" & tipo.SelectedValue & "'"
        
        Dim Reader As SqlDataReader = conection.traerDataReader(queryString, 2)
        Dim fecha As Date = Date.Now
        Context.Response.ContentType = "text/csv"
        Context.Response.AddHeader("Content-Disposition", "attachment; filename=Reposicion_SimCard" & Date.Now.Year & Date.Now.Month & Date.Now.Day & ".txt")
        Try
            Using Reader
                Response.ClearContent()
                While Reader.Read
                    Response.Write(Reader.GetValue(0) & "|" & Reader.GetValue(1) & "|" & Reader.GetValue(2) & "|" & Reader.GetValue(3) & "|" & Reader.GetValue(4) & "|" & Reader.GetValue(5) & "|" & Reader.GetValue(6) & "|" & Reader.GetValue(7) & "|" & Reader.GetValue(8) & "|" & Reader.GetValue(9) & "|" & Reader.GetValue(10) & "|" & Reader.GetValue(11) & "|" & Reader.GetValue(12) & "|" & Reader.GetValue(13) & "|" & Reader.GetValue(14) & "|" & Reader.GetValue(15) & "|" & Reader.GetValue(16) & "|" & Reader.GetValue(17) & "|" & Reader.GetValue(18) & "|" & Reader.GetValue(19) & "|" & Reader.GetValue(20) & "|" & Reader.GetValue(21) & "|" & Reader.GetValue(22) & "|" & Reader.GetValue(23) & "|" & Reader.GetValue(24) & "|" & Reader.GetValue(25) & "|" & Reader.GetValue(26) & "|" & Reader.GetValue(27) & "|" & Reader.GetValue(28) & "|" & Reader.GetValue(29) & vbCrLf)
                End While
                Reader.Close()
                Response.End()
            End Using
        Finally
        End Try
        Response.End()
    End Sub
	
	' 22735 - Reposicion SIMCARD corporativo - validar boton cancelar
	Protected Function MostrarBtnCancelar(estadoT As Object) as Boolean
		If estadoT.ToString() = "Pendiente" Then
			Return True
		Else
			Return False
		End If
    End Function

	
	' 22735 - Reposicion SIMCARD corporativo - cancelar solicitud
	Protected Sub cancelar_click (sender As Object, e As EventArgs)
		Dim btn As Button = DirectCast(sender, Button )
		Dim id_sim As String = Int32.Parse(btn.CommandArgument)
		Dim estadoC as String = "C"
		Try
			cancelar_clic_axis(id_sim, estadoC)
			ds_cancelar_sol.UpdateParameters.Item("estado").DefaultValue = estadoC
			ds_cancelar_sol.UpdateParameters.Item("id_padre_sim").DefaultValue = id_sim
			ds_cancelar_sol.Update()
			'Response.Redirect("consulta.aspx")
		Catch ex As Exception
			Response.Write("ERROR!!! " & ex.ToString())
		End Try
    End Sub

	Protected Sub cancelar_clic_axis (id_sim As Integer, estadoC As String)
		Try
			'Variables para conexion
			Dim conn2 As System.Data.OracleClient.OracleConnection
			Dim cmd2 As System.Data.OracleClient.OracleCommand

			conn2 = New System.Data.OracleClient.OracleConnection(ConfigurationManager.ConnectionStrings("OracleAxisConnectionString").ConnectionString)
			cmd2 = New System.Data.OracleClient.OracleCommand("PORTA.CLK_REPOSICION_SIM_EN_LINEA.P_ACTUALIZA_BITACORA_SIM", conn2)
			cmd2.CommandType = CommandType.StoredProcedure
			
			conn2.Open()
			cmd2.Parameters.AddWithValue("PN_ID_SIMCARD_PR", id_sim)
			cmd2.Parameters.AddWithValue("PV_ESTADO", estadoC)
			
			conn2.Close()
			conn2.Dispose()
		Catch ex As Exception
			Response.Write("ERROR!!! " & ex.ToString())
		End Try
	End Sub
	
</script>


<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Reposici&#243;n de Simcard | Consulta</title>
    <script language="javascript" src="/portalsco/include/js/calendar/popcalendar.js"></script>
    <LINK href="/portalsco/include/js/calendar/popcalendar.css" type="text/css" rel="stylesheet"> 
    
<script language="javascript" >
  //<![CDATA[
  function Fecha(){
var v=document.form1.rango;
var v1=document.form1.fecha_i;
var v2=document.form1.fecha_f;
var v3=document.form1.imgFi;
var v4=document.form1.imgFf;


var estado;
if (v.checked){
	estado=false;
	}
else {
	estado=true;
	}
	v1.disabled=estado;
	v2.disabled=estado;
	v3.disabled=estado;
	v4.disabled=estado;
}
 
  //]]>
 </script>
   
    <style type="text/css">
        .style1
        {
            height: 20px;
        }
    </style>
   
</head>
<body onload="Fecha()" topmargin="0" leftmargin="0" rightmargin="0" >
    <form id="form1" runat="server">
    <div>
        <table cellpadding="0" cellspacing="0" width="100%" style="height: 88px">
            <tbody>
                <tr>
                    <td background="../../../images/apl/simcard.jpg" >
                    </td>
        
                </tr>
            </tbody>
        </table>
        <uc1:menu ID="Menu1" runat="server" />
        <br />
        <br />
        <br />
        <br />
        <table border="0" bordercolor="silver" cellpadding="1" cellspacing="0" align="center" width="650">
            <tr>
                <td >
                    <strong><span style="color: #000000">
                    Nombre del Cliente:</span></strong></td>
                <td >
                            <asp:TextBox ID="nom" runat="server" MaxLength="40" Width="210px"></asp:TextBox></td>
                <td>
                    <strong><span style="color: #000000">Login:</span></strong></td>
                <td>
                    <asp:Label ID="Label4" runat="server" Text="No ha iniciado sesión" Font-Bold="True" ForeColor="Black"></asp:Label></td>
            </tr>
            <tr>
                <td>
                    <strong><span style="color: #000000">
                    Asesor Empresarial:</span></strong></td>
                <td>
                    <asp:DropDownList ID="ases" runat="server" AppendDataBoundItems="True" DataSourceID="ds_ases"
                        DataTextField="usuario" DataValueField="username" Width="120px">
                        <asp:ListItem Selected="True" Value="-">-Todos-</asp:ListItem>
                    </asp:DropDownList></td>
                <td >
                    <strong><span style="color: #000000">
                    No. Tramite:</span></strong></td>
                <td >
                    <asp:TextBox ID="tram" runat="server" MaxLength="9" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                        Width="120px"></asp:TextBox></td>
            </tr>
            <tr>
                <td>
                    <strong><span style="color: #000000">Tipo Cliente:</span></strong></td>
                <td>
                    <asp:DropDownList ID="tipo" runat="server" Width="120px">
                        <asp:ListItem Value="-1">-Todos-</asp:ListItem>
                        <asp:ListItem Value="V">VIP</asp:ListItem>
                        <asp:ListItem Value="P">PYMES</asp:ListItem>
                    </asp:DropDownList></td>
                <td>
                    <strong><span style="color: #000000">
                    Usuario Asignado:</span></strong></td>
                <td>
                    <asp:DropDownList ID="login" runat="server" AppendDataBoundItems="True" 
                        DataSourceID="ds_asesor" DataTextField="usuario" DataValueField="username" 
                        Width="120px">
                        <asp:ListItem Value="--">-Todos-</asp:ListItem>


                    </asp:DropDownList>
                    <asp:SqlDataSource ID="ds_asesor" runat="server" 
                        ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>" SelectCommand="select username, E.nombre+' '+E.apellido as usuario
from aspnet_users A
inner join aspnet_usersinroles B on A.userid=B.userid
inner join aspnet_roles C on B.roleid=C.roleid
inner join aspnet_membership D on A.userid=D.userid
inner join aspnet_perfiles E on A.userid=E.userid
where c.rolename in ('Apl Reposicion Sim R1','Apl Reposicion Sim R2') and D.isapproved='1'
order by c.rolename, e.nombre, e.apellido"></asp:SqlDataSource>
                </td>
            </tr>
            <tr>
                <td class="style1" >
                    <strong><span style="color: #000000">
                    Cta. Axis:</span></strong></td>
                <td class="style1" >
                    <asp:TextBox ID="axis" runat="server" MaxLength="10" onkeypress="if ((event.keyCode > 0 && event.keyCode < 46)|| (event.keyCode == 47)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                        Width="120px"></asp:TextBox></td>
                <td class="style1">
                    <strong><span style="color: #000000">
                    Región del Cliente:</span></strong></td>
                <td class="style1" >
                    <asp:DropDownList ID="cmb_id_region" runat="server" Width="120px">
                        <asp:ListItem Value="-1">-Todos-</asp:ListItem>
                        <asp:ListItem Value="R1">R1 - UIO</asp:ListItem>
                        <asp:ListItem Value="R2">R2 - GYE</asp:ListItem>
                    </asp:DropDownList></td>
            </tr>
            <tr>
                <td>
                    <strong><span style="color: #000000">
                    Número Reposición:</span></strong></td>
                <td>
                    <asp:TextBox ID="num_repo" runat="server" MaxLength="10" onkeypress="if ((event.keyCode > 0 && event.keyCode < 46)|| (event.keyCode == 47)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                        Width="120px"></asp:TextBox></td>
                <td>
                    <strong><span style="color: #000000">Reporte Archivo Texto:</span></strong></td>
                <td>
                <asp:Image ID="Image1" runat="server" ImageUrl="~/images/Iconos/bloc.jpg" />
                    &nbsp;
                    <asp:LinkButton ID="LinkButton1" runat="server" OnClick="LinkButton1_Click">Descarga Archivo</asp:LinkButton>
                </td>
            </tr>
            <tr>
                <td>
                    <strong><span style="color: #000000">Estado:</span></strong></td>
                <td>
                                
                                    <asp:DropDownList ID="estado" runat="server" Width="120px">
                                        <asp:ListItem Value="-">-Todos-</asp:ListItem>
										<asp:ListItem Value="X">Pendiente</asp:ListItem>
                                        <asp:ListItem Value="I">Ingresado</asp:ListItem>
                                        <asp:ListItem Value="P">En Proceso</asp:ListItem>
                                        <asp:ListItem Value="F">Facturaci&#243;n</asp:ListItem>
                                        <asp:ListItem Value="E">En Proceso Entrega</asp:ListItem>
                                        <asp:ListItem Value="A">Activado</asp:ListItem>
                                        <asp:ListItem Value="R">Rechazado</asp:ListItem>
										<asp:ListItem Value="C">Cancelado</asp:ListItem>
                                    </asp:DropDownList></td>


                    <td>
                    <asp:TextBox ID="txt_control_region" runat="server" Visible="False" 
                        AutoPostBack="True"></asp:TextBox>
                    </td>
                <td>
                    </td>
                <td>
                    </td>
            </tr>
            <tr>
                <td >
                    <strong><span style="color: #000000">Fecha:</span></strong></td>
                <td style="text-align: left">
                                <asp:TextBox ID="fecha_i" runat="server" MaxLength="10" Width="70px"></asp:TextBox>
                    &nbsp;<img id="imgFi" alt="calendar" height="17" name="imgFi" onclick="popUpCalendar(this,fecha_i, 'dd/mm/yyyy');"
                                    src="../../../images/apl/calendario.gif" style="cursor: hand" width="22" align="absMiddle" />&nbsp;
                                <asp:TextBox ID="fecha_f" runat="server" MaxLength="10" Width="70px"></asp:TextBox>&nbsp;
                    <img id="imgFf" alt="calendar" height="17" name="imgFf" onclick="popUpCalendar(this,fecha_f, 'dd/mm/yyyy');"
                                    src="../../../images/apl/calendario.gif" style="cursor: hand" width="22" align="absMiddle" /></td>
                <td style="text-align: center" >
                    <asp:Button ID="Btn_consultar" runat="server" OnClick="Btn_consultar_Click" Text="Consultar" Font-Bold="True" /></td>
                <td style="text-align: left">
                    </td>
            </tr>
        </table>
                    <br />
        <%If User.IsInRole("Administrador") Or User.IsInRole("Supervisor Porta") Or User.IsInRole("Supervisor OPE") Or User.IsInRole("APL Reposicion Sim") Then%>&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                   <%end if %>
                   </div>
                <asp:GridView ID="GridView1" runat="server" AllowPaging="True" DataSourceID="ds_con" Width="100%" SkinID="porta" AllowSorting="True" AutoGenerateColumns="False" DataKeyNames="id_sim">
                    <EmptyDataTemplate>
                        No hay datos con la consulta realizada
                    </EmptyDataTemplate>
                    <Columns>
                    <asp:TemplateField >
                   <ItemTemplate><a  href="javascript:;" onclick="window.open('detalle.aspx?id_sim=<%# eval("id_sim") %>','')"><img src="../../../images/apl/search.gif" title="Detalles" width="16" height="16" /></a> 
                    </ItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" />
                        <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="No. Tr&#225;mite" SortExpression="id_padre">
                    <ItemTemplate>
                        <asp:Label ID="Label15" runat="server" Text='<%# Bind("id_padre") %>'></asp:Label><br />
                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                 <asp:TemplateField HeaderText="Fecha de Ingreso" SortExpression="fecha_ing">
                    <ItemTemplate>
                        <asp:Label ID="Label16" runat="server" Text='<%# Bind("fecha_ing") %>'></asp:Label><br />
                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Datos del Cliente" SortExpression="nombre">
                    <ItemTemplate>
                        <asp:Label ID="Label25" runat="server" Text='<%# Bind("nom_cliente") %>'></asp:Label><br />
                        <asp:Label ID="Label29" runat="server" Text='<%# Bind("cta_axis") %>'></asp:Label><br />
                        <img id="img10" title="cssbody=[boxbody] cssheader=[boxheader] header=[DIRECCIÓN:] body=[<%# eval("direccion")  %> ]" src="../../../images/Scripts/adicional.gif" width="18" height="18" /> 
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                        
                         <asp:TemplateField HeaderText="Datos de Contacto" SortExpression="nom_contacto">
                    <ItemTemplate>
                        <asp:Label ID="Label5" runat="server" Text='<%# Bind("nom_contacto") %>'></asp:Label><br />
                        <b>Contacto 1: </b><asp:Label ID="Label6" runat="server" Text='<%# Bind("telf_contacto") %>'></asp:Label><br />
          <b>Contacto 2: </b><asp:Label ID="Label1" runat="server" Text='<%# Bind("telf_contacto2") %>'></asp:Label>                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Datos del Tr&#225;mite" SortExpression="login">
                    <ItemTemplate>
                        <img id="img10" title="cssbody=[boxbody] cssheader=[boxheader] header=[OBSERVACIÓN:] body=[<%# eval("observacion")  %> ]" src="../../../images/Scripts/adicional.gif" width="18" height="18" /><br />
                        <b>Login: </b><asp:Label ID="Label26" runat="server" Text='<%# Bind("login") %>'></asp:Label><br /> 
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Datos de Respuesta" SortExpression="ultima_obs">
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <ItemTemplate >
                    <img id="img3" title="cssbody=[boxbody] cssheader=[boxheader] header=[RESPUESTA:] body=[<%# eval("ultima_obs")  %> ]" src="../../../images/Scripts/adicional.gif" width="18" height="18" /><br />
                    <b>Asignado: </b><asp:Label ID="Label7" runat="server" Text='<%# Bind("ultimo_login") %>'></asp:Label><br />
                    <b>Fecha: </b><asp:Label ID="Label8" runat="server" Text='<%# Bind("ultima_fecha", "{0:d}") %>'></asp:Label>
                     </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <HeaderStyle CssClass="p_gridview_h" />
                </asp:TemplateField>
                        <asp:TemplateField HeaderText="Estado" SortExpression="estado">
                            <EditItemTemplate>
                                <asp:TextBox ID="TextBox1" runat="server" Text='<%# Bind("estado") %>'></asp:TextBox>
                            </EditItemTemplate>
                            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                            <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                            <ItemTemplate>
                                <asp:Label ID="Label3" runat="server" Text='<%# Bind("estado") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="tipo" HeaderText="Tipo" SortExpression="tipo">
                            <HeaderStyle CssClass="p_gridview_h" />
                        </asp:BoundField>
						<asp:TemplateField HeaderText="Cancelar Tr&#225;mite">
                            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                            <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                            <ItemTemplate>
                                <asp:Button ID="CancelButton1" runat="server" Text="Cancelar" Font-Bold="True"
                                    OnClick="cancelar_click" CommandArgument='<%# Eval("id_sim") %>'
                                    Enabled='<%# MostrarBtnCancelar(Eval("estado")) %>'></asp:Button>
                            </ItemTemplate>
                        </asp:TemplateField>
						
                    </Columns>
                </asp:GridView>
                
        <asp:SqlDataSource ID="ds_con" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
            SelectCommand="SET DATEFORMAT DMY
SELECT A.id_sim, fecha_ing, nom_cliente, cta_axis, direccion, nom_contacto, telf_contacto, telf_contacto2, login, observacion, region_cliente, b.id_padre, b.ultima_obs, b.ultimo_login, b.ultimo_estado, case a.tipo when 'P' then 'CORPORATIVO' when 'V' then 'VIP' end as tipo,b.ultima_fecha,
CASE b.ultimo_estado
WHEN 'X' THEN 'Pendiente' 
WHEN 'I' THEN 'Ingresado' 
WHEN 'P' THEN 'En Proceso'
WHEN 'F' THEN 'Facturación'
WHEN 'E' THEN 'En Proceso Entrega' 
WHEN 'A' THEN 'Activado' 
WHEN 'R' THEN 'Rechazado' 
WHEN 'C' THEN 'Cancelado' 
END AS estado
FROM Tbl_atv_reposicion_sim A
INNER JOIN Tbl_atv_reposicion_sim_proceso B ON (A.id_sim=B.id_padre)
left JOIN Tbl_atv_reposicion_sim_detalle C ON (A.id_sim=C.id_sim)
WHERE (@nom='aaa' or (@nom&lt;&gt;'aaa' and A.nom_cliente like + @nom +'%')) and (@tram='000' or (@tram&lt;&gt;'000' and A.id_sim like + @tram +'%')) and (@axis='999' or (@axis&lt;&gt;'999' and A.cta_axis like + @axis +'%'))  and ((@repo='000' or (@repo&lt;&gt;'000' and C.telefono_Reposicion like + @repo +'%')) or (@repo='000' or (@repo&lt;&gt;'000' and A.num_repo like + @repo +'%'))) and  (@login='--' or (@login&lt;&gt;'--' and B.ultimo_login=@login)) and (@est='-' or (@est&lt;&gt;'-' and B.ultimo_estado=@est)) and (@ases='-' or (@ases&lt;&gt;'-' and A.nom_ases=@ases)) 
and (@tipo='-1' or (@tipo&lt;&gt;'-1' and A.tipo=@tipo)) 
and  ( A.fecha_ing between cast(@fi +' 00:00:00.000' as datetime) and cast(@ff +' 23:59:59.999'  as  datetime))
and (@region = '-1' or (@region&lt;&gt;'-1' and A.region_cliente = @region))
GROUP BY A.id_sim, fecha_ing, nom_cliente, cta_axis, direccion, nom_contacto, telf_contacto, telf_contacto2, login, observacion, region_cliente, b.id_padre, b.ultima_obs, b.ultimo_login, b.ultimo_estado, a.tipo,b.ultima_fecha,b.ultimo_estado
ORDER BY  fecha_ing DESC" CancelSelectOnNullParameter="False">
            <SelectParameters>
                <asp:ControlParameter ControlID="nom" DefaultValue="aaa" Name="nom" PropertyName="Text" />
                <asp:ControlParameter ControlID="login" DefaultValue="" Name="login" PropertyName="SelectedValue" />
                <asp:ControlParameter ControlID="estado" Name="est" PropertyName="SelectedValue" />
                <asp:ControlParameter ControlID="ases" Name="ases" PropertyName="SelectedValue" />
                <asp:Parameter DefaultValue="off" Name="rango" />
                <asp:ControlParameter ControlID="fecha_i" DefaultValue="" Name="fi" PropertyName="Text" />
                <asp:ControlParameter ControlID="fecha_f" Name="ff" PropertyName="Text" />
                <asp:ControlParameter ControlID="tram" DefaultValue="000" Name="tram" PropertyName="Text" />
                <asp:ControlParameter ControlID="axis" DefaultValue="999" Name="axis" PropertyName="Text" />
                <asp:ControlParameter ControlID="num_repo" DefaultValue="000" Name="repo" PropertyName="Text" />
                <asp:ControlParameter ControlID="tipo" DefaultValue="-1" Name="tipo" 
                    PropertyName="SelectedValue" />
                <asp:ControlParameter ControlID="cmb_id_region" DefaultValue="-1" Name="region" 
                    PropertyName="SelectedValue" />
            </SelectParameters>
        </asp:SqlDataSource>
        <asp:SqlDataSource ID="ds_ases" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
            SelectCommand="select username, E.nombre+' '+E.apellido as usuario&#13;&#10;from aspnet_users A&#13;&#10;inner join aspnet_usersinroles B on A.userid=B.userid&#13;&#10;inner join aspnet_roles C on B.roleid=C.roleid&#13;&#10;inner join aspnet_membership D on A.userid=D.userid&#13;&#10;inner join aspnet_perfiles E on A.userid=E.userid&#13;&#10;where c.rolename='P COM Ases' and D.isapproved='1'&#13;&#10;order by e.nombre, e.apellido">
        </asp:SqlDataSource>
		<%--22735 - DATASOURCE ACTUALIZAR SOLICITUD--%>
        <asp:SqlDataSource ID="ds_cancelar_sol" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
            UpdateCommand="UPDATE Tbl_atv_reposicion_sim_proceso SET ultima_fecha=GETDATE(), ultimo_login=@login, ultimo_estado = @estado WHERE id_padre = @id_padre_sim">
            <UpdateParameters>
				<asp:SessionParameter Name="login" SessionField="USER" />
                <asp:Parameter Name="estado" />
                <asp:Parameter Name="id_padre_sim" />
            </UpdateParameters>
        </asp:SqlDataSource>
        <script language="javascript"  defer="defer"  src="/portalsco/include/js/boxover.js"></script>
    </form>
</body>
</html>

