<%--
***************************************************************************************************************
DESCRIPCION: Formulario de consulta reposicion Simcard
CREADOR: Manuel Marin
FECHA DE ACTUALIZACIÓN: 28/03/2014
***************************************************************************************************************
***************************************************************************************************************
DESCRIPCION: Formulario de detalle de reposicion Simcard
MODIFICADO POR: Cima Manuel Marín
MOTIVO DE MODIFICACIÓN: Se realizan las siguientes mejoras
                        - En el formulario de consulta se eliminan las fechas diferentes 
                          a la fecha de entrega (Fecha de facturación)
                        - En el reporte que se exporta a excel se presentan los siguientes campos:
                          = Fecha de Entrega
                          =	Cliente	Canal
                          =	Tramite
                          =	Factura
                          =	No. Simcards
                          =	No. Guia
                          =	Motivo
FECHA DE MODIFICACIÓN: 30/06/2014
***************************************************************************************************************
--%>
<%@ Page Language="VB" StylesheetTheme="White"%>


<%@ Register Src="menu.ascx" TagName="menu" TagPrefix="uc1" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ import Namespace="System.Web.Mail" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">




<script runat="server">    
   
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            txt_fecha_i.Text = "01/" & Month(Now()) & "/" & Year(Now())
            fecha_h.Text = Day(Now()) & "/" & Month(Now()) & "/" & Year(Now())
        End If
    End Sub


    Protected Sub Btn_consultar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        GridView2.DataBind()
    End Sub
    
    Protected Sub btnAgregar_Occ_Click(ByVal sender As Object, ByVal e As System.EventArgs)
                      
        Dim mifecha As String = DateTime.Now.ToShortDateString()
        Dim tramite As String = txt_tram.Text
        Dim fecha As String = txt_fecha_i.Text
        Dim dat_cliente As String = txt_nom.Text
        Dim dat_contacto As String = txt_dat_contact.Text
        Dim dat_tramite As String = txt_num_repo.Text
        Dim tipo_estado As String = ddl_estado.Text
        
        ds_consulta_recibido.DataBind()
        GridView2.DataBind()
    End Sub
    
    Protected Sub LinkButton2_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim reporte As String = ""
        reporte = "reporte_excel_sim.aspx?&fi=" & txt_fecha_i.Text & "&ff=" & fecha_h.Text & ""
        Response.Redirect(reporte)
    End Sub


</script>


<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Reposici&#243;n de Simcard | Consulta</title>
    <script language="javascript" src="/portalsco/include/js/calendar/popcalendar.js"></script>
    <LINK href="/portalsco/include/js/calendar/popcalendar.css" type="text/css" rel="stylesheet"> 
    
<script language="javascript" >


 </script>
   
</head>
<%--onload="Fecha()" --%>
<body topmargin="0" leftmargin="0" rightmargin="0" >
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
        <table border="0" bordercolor="silver" cellpadding="1" cellspacing="0" align="center" width="450">
             <tr>
            <td >
                    <strong><span style="color: #000000">
                    No. Tramite:</span></strong></td>
                <td >
                    <asp:TextBox ID="txt_tram" runat="server" MaxLength="9" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                        Width="76px"></asp:TextBox></td>
              </tr>


               <tr>
                <td >
                    <strong><span style="color: #000000">Fecha de Ingreso:</span></strong></td>
                <td style="text-align: left">
                                <asp:TextBox ID="txt_fecha_i" runat="server" MaxLength="10" Width="70px"  onKeypress="if ((event.keyCode > 0 && event.keyCode < 47)|| (event.keyCode > 57 && event.keyCode < 256) ) event.returnValue = false;">  </asp:TextBox>
                    &nbsp;<img id="imgFi" alt="calendar" height="17" name="imgFi" onclick="popUpCalendar(this,txt_fecha_i, 'dd/mm/yyyy');"
                                    src="../../../images/apl/calendario.gif" style="cursor: hand" width="22" align="absMiddle" />&nbsp;
                             
                             Hasta :
                                <asp:TextBox ID="fecha_h" runat="server" MaxLength="10" Width="70px"  onKeypress="if ((event.keyCode > 0 && event.keyCode < 47)|| (event.keyCode > 57 && event.keyCode < 256) ) event.returnValue = false;">  </asp:TextBox>
                    &nbsp;<img id="img1" alt="calendar" height="17" name="imgFi" onclick="popUpCalendar(this,fecha_h, 'dd/mm/yyyy');"
                                    src="../../../images/apl/calendario.gif" style="cursor: hand" width="22" align="absMiddle" />&nbsp;
                                           
                    </td>
            </tr>            
            <tr>
                <td >
                    <strong><span style="color: #000000">
                    Cuenta del Cliente:</span></strong></td>
                <td >
                            <asp:TextBox ID="txt_nom" runat="server" MaxLength="40" Width="210px"></asp:TextBox></td>                
            </tr>    
          
            <tr>
                <td >
                    <strong><span style="color: #000000">
                    Datos del Contacto:</span></strong></td>
                <td >
                    <asp:TextBox ID="txt_dat_contact" runat="server" MaxLength="40" Width="210px"></asp:TextBox></td>
               
            </tr>
            <tr>
                <td>
                    <strong><span style="color: #000000">
                    Número de Reposicion:</span></strong></td>
                <td>
                    <asp:TextBox ID="txt_num_repo" runat="server" MaxLength="10" onkeypress="if ((event.keyCode > 0 && event.keyCode < 46)|| (event.keyCode == 47)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                        Width="81px"></asp:TextBox></td>                
                <td>
                    &nbsp;
                </td>
            </tr>


            <tr >
             <td>
                    <strong><span style="color: #000000">
                    Usuario del Asistente:</span></strong></td>
                <td>
                    <asp:DropDownList ID="ddl_login" runat="server" AppendDataBoundItems="True" 
                        DataSourceID="ds_asesor" DataTextField="usuario" DataValueField="username">
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
            </tr>
            <tr>
              <td class="style1">
                    <strong><span style="color: #000000">
                    Región del Cliente:</span></strong></td>
                <td class="style1" >
                    <asp:DropDownList ID="ddl_region" runat="server">
                        <asp:ListItem Value="-1">-Todos-</asp:ListItem>
                        <asp:ListItem Value="R1">R1 - Sierra</asp:ListItem>
                        <asp:ListItem Value="R2">R2 - Costa</asp:ListItem>
                    </asp:DropDownList></td>
            </tr>
            <tr>
              <td class="style1">
                    <strong><span style="color: #000000">Canal:</span></strong></td>
                <td class="style1" >
                    <asp:DropDownList ID="ddl_canal" runat="server" Height="16px">
                        <asp:ListItem Value="-1">-Todos-</asp:ListItem>
                        <asp:ListItem Value="WEB">WEB</asp:ListItem>
                        <asp:ListItem Value="MOVIL_WEB">MOVIL_WEB</asp:ListItem>
                        <asp:ListItem Value="MOVIL_APP">MOVIL_APP</asp:ListItem>
                        <asp:ListItem Value="*888">*888</asp:ListItem>
                    </asp:DropDownList></td>
            </tr>
             <tr >
             <td>
                    <strong><span style="color: #000000">Ciudad:</span></strong></td>
                <td>
                    <asp:DropDownList ID="ddl_ciudad" runat="server" AppendDataBoundItems="True" DataSourceID="ds_ciudad"
                        DataTextField="nombre" DataValueField="desc_area">
                        <asp:ListItem Selected="True" Value="-">-Todos-</asp:ListItem>
                    </asp:DropDownList></td>            
            </tr>
            <tr>
                <td>
                    <strong><span style="color: #000000">Estado:</span></strong></td>
                <td>                                
                                     <asp:DropDownList ID="ddl_estado" runat="server">
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
                       
               </tr>     
               
               
               <tr>
               <td colspan="4" style="height: 13px; text-align: left;">
                   <br />
                <img src="../../../images/Iconos/hoja_excel.gif" width="16" height="17" />
                 <asp:LinkButton ID="LinkButton2" runat="server" OnClick="LinkButton2_Click">Reporte Excel</asp:LinkButton></td>
                </tr> 
                          
               <tr>
              
    <td  colspan ="2" align="center">    
        <asp:Button ID="consultar" runat="server" onclick="btnAgregar_Occ_Click" 
            Text="Consultar" Height="18px" Width="63px" Font-Bold="True" />    
    </td>
    </tr>           
        </table>
                    <br />
                    <%If User.IsInRole("Administrador") Or User.IsInRole("Supervisor Porta") Or User.IsInRole("Supervisor OPE") Or User.IsInRole("APL Reposicion Sim") Then%>
        &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                   <%end if %>
                   </div>                            
                     <asp:GridView ID="GridView2" runat="server"  AllowPaging="True" DataSourceID="ds_consulta_recibido" Width="100%" SkinID="porta" AllowSorting="True" AutoGenerateColumns="False" DataKeyNames="id_padre" >
                    <EmptyDataTemplate>
                        No hay datos con la consulta realizada
                    </EmptyDataTemplate>               
                <Columns>
                <asp:TemplateField HeaderText="No. Cuenta" SortExpression="cuenta">
                    <ItemTemplate>
                        <asp:Label ID="lbl_cuenta" runat="server" Text='<%# Bind("cuenta") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="No. Trámite" SortExpression="id_padre">
                    <ItemTemplate>
                        <asp:Label ID="lbl_id_padre" runat="server" Text='<%# Bind("id_padre") %>'></asp:Label><br />                        
                    </ItemTemplate>
                      <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                     <asp:TemplateField HeaderText="No. Factura" SortExpression="factura">
                    <ItemTemplate>
                        <asp:Label ID="lbl_factura" runat="server" Text='<%# Bind("factura") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                     <asp:TemplateField HeaderText="Cliente" SortExpression="cliente">
                    <ItemTemplate>
                        <asp:Label ID="lbl_cliente" runat="server" Text='<%# Bind("cliente") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                      <asp:TemplateField HeaderText="Fecha de Entrega" SortExpression="fecha_entrega">
                    <ItemTemplate>
                        <asp:Label ID="lbl_fecha_entrega" runat="server" Text='<%# Bind("fecha_entrega") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                     <asp:TemplateField HeaderText="Asesor Empresarial" SortExpression="asesor_comercial">
                    <ItemTemplate>
                     <asp:Label ID="lbl_asesor_comercial" runat="server" Text='<%# Bind("asesor_comercial") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Usuario Asistente del Trámite" SortExpression="usuario_asistente">
                    <ItemTemplate>
                        <asp:Label ID="lbl_usuario_asistente" runat="server" Text='<%# Bind("usuario_asistente") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Nombre de Contacto" SortExpression="nom_contact">
                    <ItemTemplate>
                        <asp:Label ID="Label15" runat="server" Text='<%# Bind("nom_contacto") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Motivo de la Reposición" SortExpression="motivo">
                    <ItemTemplate>
                        <asp:Label ID="lbl_motivo" runat="server" Text='<%# Bind("motivo") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                     <asp:TemplateField HeaderText="Cantidad de Simcards" SortExpression="cantidad_registro">
                    <ItemTemplate>
                        <asp:Label ID="lbl_cantidad_registro" runat="server" Text='<%# Bind("cantidad_registro") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                      <asp:TemplateField HeaderText="No. de Guía de Remisión " SortExpression="guia_remision">
                    <ItemTemplate>
                        <asp:Label ID="lbl_guia_remision" runat="server" Text='<%# Bind("guia_remision") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                     <asp:TemplateField HeaderText="Estado del Trámite" SortExpression="ESTADO">
                    <ItemTemplate>
                        <asp:Label ID="lbl_estado" runat="server" Text='<%# Bind("ESTADO") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                     <asp:TemplateField HeaderText="Canal" SortExpression="medio">
                    <ItemTemplate>
                        <asp:Label ID="lbl_medio" runat="server" Text='<%# Bind("medio") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Recibido por " SortExpression="recibido_por">
                    <ItemTemplate>
                        <asp:Label ID="lbl_recibido_por" runat="server" Text='<%# Bind("recibido_por") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                     <asp:TemplateField HeaderText="Region" SortExpression="region">
                    <ItemTemplate>
                        <asp:Label ID="lbl_region" runat="server" Text='<%# Bind("region") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Ciudad" SortExpression="ciudad">
                    <ItemTemplate>
                        <asp:Label ID="lbl_ciudad" runat="server" Text='<%# Bind("ciudad") %>'></asp:Label><br />                        
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <HeaderStyle CssClass="p_gridview_h" HorizontalAlign="Center" VerticalAlign="Middle" />
                    </asp:TemplateField>                
                </Columns>               
            </asp:GridView>  
            
         <asp:SqlDataSource ID="ds_ciudad" runat="server" ConnectionString="<%$ ConnectionStrings:CRMConnectionString %>"
            SelectCommand="SELECT  DISTINCT ( b.po_descripcion + ' - ' + a.desc_area ) AS nombre, a.desc_area &#13;&#10;FROM  intr_call.dbo.Tbl_D_CodigoArea a&#13;&#10;INNER JOIN  intr_call.dbo.Tbl_M_provincia b ON a.po_codigo = b.po_codigo &#13;&#10;WHERE (a.codigo_pais = 18)&#13;&#10;ORDER BY NOMBRE">
        </asp:SqlDataSource>  




              <asp:SqlDataSource ID="ds_consulta_recibido" runat="server" 
            ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>" 
            SelectCommand= "SET DATEFORMAT DMY
                            select a.cuenta,
                                   b.id_padre,
                                   b.factura,
                                   a.cliente, CONVERT (varchar(10), CAST(b.fecha_entrega AS datetime), 103) as fecha_entrega,b.ultima_fecha,b.fecha_entrega,c.fecha_ing,
                                   c.cta_axis,a.asesor_comercial,b.motivo,a.cantidad_registro,b.guia_remision,
                                   b.recibido_por,a.region,a.ciudad,c.nom_contacto,c.num_repo,a.medio,b.usuario_asistente,CASE b.ultimo_estado WHEN 'I' 
                                   THEN 'INGRESADO' WHEN 'P' THEN 'EN PROCESO DE ENTREGA' WHEN 'F' THEN 'FACTURACION' WHEN 'E' THEN 'EN PROCESO' WHEN 'A' 
                                   THEN 'ACTIVADO' WHEN 'R' THEN 'RECHAZADO' WHEN 'X' THEN 'PENDIENTE' WHEN 'C' THEN 'CANCELADO' END AS ESTADO
                           from 
                                tbl_atv_reposicion_sim_proceso b 
                                left join tbl_atv_reposicion_sim c on c.id_sim = b.id_padre 
                                left join tbl_bitacora_ws_solicitud_sim a on a.id_sim = b.id_padre 
                           where b.id_padre=c.id_sim
                                and c.id_sim=a.id_sim 
                                and  (@tramite='000' or (@tramite<>'000' and a.id_sim =@tramite)) 
                                and  (@dat_cliente='aaa' or (@dat_cliente<>'aaa' and a.cuenta =@dat_cliente))
                                and  (@dat_contacto='aaa' or (@dat_contacto<>'aaa' and c.nom_contacto =@dat_contacto)) 
                                and (@dat_tramite='999' or (@dat_tramite<>'999' and c.num_repo =@dat_tramite)) 
                                and (@login='--' or (@login<>'--' and b.usuario_asistente=@login)) 
                                and (@region='-1' or (@region<>'-1' and a.region=@region))
                                and (@canal='-1' or (@canal<>'-1' and a.medio=@canal))
                                and (@ciudad='-' or (@ciudad<>'-' and a.ciudad=@ciudad))  
                                and (@tipo_estado='-' or (@tipo_estado<>'-' and b.ultimo_estado =@tipo_estado))
                                and  c.fecha_ing  between cast(@fi +' 00:00:00.000' as datetime) and cast(@ff +' 23:59:59.999'  as  datetime)
                             ORDER BY  c.fecha_ing DESC" >
                 <SelectParameters>
                     <asp:ControlParameter ControlID="txt_tram" Name="tramite" PropertyName="Text" DefaultValue="000" />
                     <asp:ControlParameter ControlID="txt_fecha_i" Name="fi" PropertyName="Text" DefaultValue=""/>
                     <asp:ControlParameter ControlID="fecha_h" Name="ff" PropertyName="Text" DefaultValue=""/>
                     <asp:ControlParameter ControlID="txt_nom" Name="dat_cliente" PropertyName="Text" DefaultValue="aaa"/>
                     <asp:ControlParameter ControlID="txt_dat_contact" Name="dat_contacto" PropertyName="Text" DefaultValue="aaa"/>    
                     <asp:ControlParameter ControlID="txt_num_repo" Name="dat_tramite" PropertyName="Text" DefaultValue="999"/> 
                     <asp:ControlParameter ControlID="ddl_Estado" Name="tipo_estado" PropertyName="SelectedValue" DefaultValue="-"/>    
                     <asp:ControlParameter ControlID="ddl_login" Name="login" PropertyName="SelectedValue" DefaultValue="--"/>
                     <asp:ControlParameter ControlID="ddl_region" Name="region" PropertyName="SelectedValue" DefaultValue="-1"/>  
                     <asp:ControlParameter ControlID="ddl_canal" Name="canal" PropertyName="SelectedValue" DefaultValue="-1"/>  
                     <asp:ControlParameter ControlID="ddl_ciudad" Name="ciudad" PropertyName="SelectedValue" DefaultValue="-"/>                      
                 </SelectParameters>
              </asp:SqlDataSource>
          <script language="javascript"  defer="defer"  src="/portalsco/include/js/boxover.js"></script>
    </form>
</body>
</html>

