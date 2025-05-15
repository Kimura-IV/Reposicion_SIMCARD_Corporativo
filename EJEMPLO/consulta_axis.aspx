<%--<%@ Page Language="VB" StylesheetTheme="White" MaintainScrollPositionOnPostback="true"
    Debug="true" %>--%>
    <%@ Page Language="VB" StylesheetTheme="White2" EnableEventValidation="false" Debug="true"
    MaintainScrollPositionOnPostback="true" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OracleClient" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="System.Data.Odbc" %>
<%@ Import Namespace="System.Oracle.DataAccess.Client" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
<%--
*********************************************************************************
Proyecto: [9625]Ventas Inteligentes
Fecha de actualizacion:27/11/2014
Creado por: SIS RChalen CIMA Emilio Zamora
Descripcion: Se agrego Consulta axis para ventas_agenda
***********************************************************************************
--%>
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim cedula As String
        'cedula = "0919954271"
        'txt_cedula.Text = cedula
        'txt_nombre.Text = "Emilio Zamora"
		txt_cedula.Text = Request.QueryString("numero")
        txt_nombre.Text = Request.QueryString("cliente")
        'gw_planes.DataBind()
        obtenerConsumo()
        obtenerDeuda()
    End Sub
    'Owner ORACLE
    'Private owner As String = "portarch" 'Desarrollo
    Private conn9 As System.Data.OracleClient.OracleConnection
    Private cmd9 As System.Data.OracleClient.OracleCommand
    Private owner As String = "porta" ' Producción
    Protected Sub obtenerConsumo()
        
        Dim conn9 As OracleConnection = New System.Data.OracleClient.OracleConnection(connectionString:=ConfigurationManager.ConnectionStrings("OracleAxisConnectionString").ConnectionString)
        cmd9 = New OracleCommand()
        cmd9.Parameters.Add(New OracleParameter("pv_id_cedula", OracleType.NVarChar)).Value = Me.txt_cedula.Text
        cmd9.Parameters.Add("o_cursor", OracleType.Cursor)
        cmd9.Parameters("o_cursor").Direction = ParameterDirection.Output
        cmd9.CommandText = (owner + ".CLK_TRX_AGE_VENTAS.clp_consulta_consumo_aux") 
		'cmd9.CommandText = (owner + ".clp_consulta_consumo_aux")
        cmd9.CommandType = CommandType.StoredProcedure
        cmd9.Connection = conn9
        Dim oda As OracleDataAdapter = New OracleDataAdapter(cmd9)
        Dim ods As DataSet = New DataSet
        Try
            conn9.Open()
            oda.Fill(ods)
            gw_consumo.DataSource = ods
            gw_consumo.DataBind()
        Catch ex As Exception
           
        Finally
            oda.Dispose()
            cmd9.Dispose()
            conn9.Close()
            conn9.Dispose()
        End Try
    End Sub
    Protected Sub obtenerDeuda()
        
        Dim conn9 As OracleConnection = New System.Data.OracleClient.OracleConnection(connectionString:=ConfigurationManager.ConnectionStrings("OracleAxisConnectionString").ConnectionString)
        cmd9 = New OracleCommand()
        cmd9.Parameters.Add(New OracleParameter("PV_ID_CEDULA", OracleType.NVarChar)).Value = Me.txt_cedula.Text
        cmd9.Parameters.Add("o_cursor", OracleType.Cursor)
        cmd9.Parameters("o_cursor").Direction = ParameterDirection.Output
        cmd9.CommandText = (owner + ".CLK_TRX_AGE_VENTAS.CLP_CONSULTA_DEUDA_AUX") 
		'cmd9.CommandText = (owner + ".CLP_CONSULTA_DEUDA_AUX") 
        cmd9.CommandType = CommandType.StoredProcedure
        cmd9.Connection = conn9
        Dim oda As OracleDataAdapter = New OracleDataAdapter(cmd9)
        Dim ods As DataSet = New DataSet
        Try
            conn9.Open()
            oda.Fill(ods)
            gw_deuda.DataSource = ods
            gw_deuda.DataBind()
        Catch ex As Exception
           
        Finally
            oda.Dispose()
            cmd9.Dispose()
            conn9.Close()
            conn9.Dispose()
        End Try
    End Sub
</script>
<head id="Head1" runat="server">
    <title>:: CRM ventas Movil | Deudas/Consumo ::</title>
    <script type="text/javascript" language="javascript" src="/portalclaro/include/box/BoxOver.js"></script>
</head>
<body>
    <form id="form1" runat="server">
     <div>
    <table align="center">
        <tr>
            <td class="red" colspan="4" align="left">
                Infomacion Personal
            </td>
        </tr>
        <tr>
            <td nowrap="2" class="style2">
                Nombre del Cliente:
            </td>
            <td class="style5">
                <asp:TextBox ID="txt_nombre" runat="server" Width="149px" Enabled="false"></asp:TextBox>
            </td>
            <td nowrap="2" class="style4">
                Ced/Ruc/Pass:
            </td>
            <td class="cem" style="width: 130px">
                <asp:TextBox ID="txt_cedula" runat="server" Width="124px" Enabled="false"></asp:TextBox>
            </td>
        </tr>
   <%-- </table>
    <br />

    <table align="left">--%>
        <tr>
            <td class="red" colspan="4" align="left">
                Consumos:
            </td>
            <br />
        </tr>
        <tr>
            <td colspan="4" align="left">
                <asp:GridView ID="gw_consumo" runat="server" AutoGenerateColumns="False" PageSize="10"
                    SkinID="porta">
                    <Columns>
                        <asp:BoundField DataField="ID_SERVICIO" HeaderText="No. Servicio" SortExpression="num_tramite">
                            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                            <HeaderStyle CssClass="p_gridview_h" Font-Names="Verdana,Arial,Helvetica,Geneva,sans-serif"
                                Font-Size="10px" HorizontalAlign="Center" VerticalAlign="Middle" />
                        </asp:BoundField>
                        <asp:BoundField DataField="BP_PLAN" HeaderText="No. Servicio" SortExpression="num_tramite">
                            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                            <HeaderStyle CssClass="p_gridview_h" Font-Names="Verdana,Arial,Helvetica,Geneva,sans-serif"
                                Font-Size="10px" HorizontalAlign="Center" VerticalAlign="Middle" />
                        </asp:BoundField>
                        <asp:BoundField DataField="CONSUMO_V" HeaderText="Consumo VOZ" SortExpression="voz">
                            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                            <HeaderStyle CssClass="p_gridview_h" Font-Names="Verdana,Arial,Helvetica,Geneva,sans-serif"
                                Font-Size="10px" HorizontalAlign="Center" VerticalAlign="Middle" />
                        </asp:BoundField>
                        <asp:BoundField DataField="CONSUMO_S" HeaderText="Consumo SMS" SortExpression="sms">
                            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                            <HeaderStyle CssClass="p_gridview_h" Font-Names="Verdana,Arial,Helvetica,Geneva,sans-serif"
                                Font-Size="10px" HorizontalAlign="Center" VerticalAlign="Middle" />
                        </asp:BoundField>
                        <asp:BoundField DataField="CONSUMO_M" HeaderText="Consumo MEGAS" SortExpression="megas">
                            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                            <HeaderStyle CssClass="p_gridview_h" Font-Names="Verdana,Arial,Helvetica,Geneva,sans-serif"
                                Font-Size="10px" HorizontalAlign="Center" VerticalAlign="Middle" />
                        </asp:BoundField>
                        <%--*******************************************fin Gestion Tramite****************************************************--%>
                    </Columns>
                    <EmptyDataTemplate>
                        No existe historial con el número ingresado
                    </EmptyDataTemplate>
                </asp:GridView>
            </td>
        </tr>
   <%-- </table>
    <table align="center" cellpadding="0" cellspacing="0" style="text-align: center;
        height: 51px; width: 78%;">--%>
        <tr>
            <td class="red" colspan="4" align="left">
                Deudas:
            </td>
            <br />
        </tr>
        <tr>
            <td colspan="4" align="left">
                <asp:GridView ID="gw_deuda" runat="server" AutoGenerateColumns="False" PageSize="10"
                    SkinID="porta">
                    <Columns>
                        <asp:BoundField DataField="ID_SERVICIO" HeaderText="No. Servicio" SortExpression="num_tramite">
                            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                            <HeaderStyle CssClass="p_gridview_h" Font-Names="Verdana,Arial,Helvetica,Geneva,sans-serif"
                                Font-Size="10px" HorizontalAlign="Center" VerticalAlign="Middle" />
                        </asp:BoundField>
                        <asp:BoundField DataField="BP_PLAN" HeaderText="BP-PLAN" SortExpression="PLAN">
                            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                            <HeaderStyle CssClass="p_gridview_h" Font-Names="Verdana,Arial,Helvetica,Geneva,sans-serif"
                                Font-Size="10px" HorizontalAlign="Center" VerticalAlign="Middle" />
                        </asp:BoundField>
                        <asp:BoundField DataField="DEUDA" HeaderText="Saldo a pagar" SortExpression="SMS">
                            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                            <HeaderStyle CssClass="p_gridview_h" Font-Names="Verdana,Arial,Helvetica,Geneva,sans-serif"
                                Font-Size="10px" HorizontalAlign="Center" VerticalAlign="Middle" />
                        </asp:BoundField>
                        <asp:BoundField DataField="DEUDA_ADENDUM" HeaderText="Ademdum" SortExpression="MEGA">
                            <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                            <HeaderStyle CssClass="p_gridview_h" Font-Names="Verdana,Arial,Helvetica,Geneva,sans-serif"
                                Font-Size="10px" HorizontalAlign="Center" VerticalAlign="Middle" />
                        </asp:BoundField>
                    </Columns>
                    <EmptyDataTemplate>
                        No existe historial con el número ingresado
                    </EmptyDataTemplate>
                </asp:GridView>
            </td>
        </tr>
    </table>
    <asp:SqlDataSource ID="ds_consulta_planes" runat="server" SelectCommandType="Text"
        SelectCommand="select g.id_plan, g.observacion from ge_detalles_planes g where g.id_detalle_plan in (SELECT a.id_detalle_plan FROM CL_SERVICIOS_CONTRATADOS A, CL_PERSONAS B  WHERE B.IDENTIFICACION= @numero AND A.ID_PERSONA = B.ID_PERSONA AND A.ESTADO='A')"
        ConnectionString="<%$ ConnectionStrings:OracleAxisConnectionString %>" ProviderName="<%$ ConnectionStrings:OracleAxisConnectionString.ProviderName %>">
        <SelectParameters>
            <asp:ControlParameter PropertyName="Text" Type="String" Name="numero" ControlID="txt_cedula">
            </asp:ControlParameter>
        </SelectParameters>
    </asp:SqlDataSource>
     </div>
    </form>
</body>
</html>