<%@ Control Language="VB" ClassName="WebUserControl" %>
<script runat="server">
</script>
<asp:Menu ID="Menu1" runat="server" BackColor="#F7F6F3" DynamicHorizontalOffset="2"
    Font-Names="Verdana" Font-Size="9pt" ForeColor="DimGray" StaticSubMenuIndent="10px" Orientation="Horizontal" Width="437px">
    <StaticMenuItemStyle HorizontalPadding="5px" VerticalPadding="2px" />
    <DynamicHoverStyle BackColor="Silver" ForeColor="White" />
    <DynamicMenuStyle BackColor="#F7F6F3" />
    <StaticSelectedStyle BackColor="#5D7B9D" />
    <DynamicSelectedStyle BackColor="#5D7B9D" />
    <DynamicMenuItemStyle HorizontalPadding="5px" VerticalPadding="2px" />
    <Items>
        <asp:MenuItem ImageUrl="~/images/apl/ir_portal_borde.gif" NavigateUrl="http://pgpoportalcrm/portalclaro/portalsco.aspx"
            Text=" " Value=" "></asp:MenuItem>
        <asp:MenuItem Text="  Ingresar" Value="Ingresar" ImageUrl="~/images/Iconos/icon_ingreso.gif">
            <asp:MenuItem Text="Ingreso de Casos (Pymes, Simcard)" Value="Ingreso" NavigateUrl="~/webpages/atv/reposicion_sim/ingreso.aspx"></asp:MenuItem>

             <%--Nuevo MenuItem agregado debajo del existente--%>
            <asp:MenuItem Text="Reposición en Línea" Value="Ingreso" NavigateUrl="~/webpages/atv/reposicion_sim/reposicion_linea.aspx"></asp:MenuItem>

        </asp:MenuItem>
        <asp:MenuItem Text="  Consultas" Value="Consultas" ImageUrl="~/images/Iconos/icon_consulta.gif">
            <asp:MenuItem Text="Consulta Reposici&#243;n Simcard"
                Value="Consulta Reposici&#243;n Simdcard Pymes" NavigateUrl="~/webpages/atv/reposicion_sim/consulta.aspx"></asp:MenuItem>
        </asp:MenuItem>
        <%--CIM GORTIZ - NUEVA OPCION 20/05/2014--%>
        <asp:MenuItem Text="  Reportes" Value="Reportes" ImageUrl="~/images/Iconos/icon_grafico.gif">
            <asp:MenuItem Text="Reporte Grafico Consolidado" Value="Reporte Grafico Consolidado" NavigateUrl="~/webpages/atv/reposicion_sim/reporte_grafico.aspx">
            </asp:MenuItem>
             <asp:MenuItem Text="Reporte Soporte Empresarial"
               Value="Reporte Soporte Empresarial" NavigateUrl="~/webpages/atv/reposicion_sim/consulta_reporte.aspx"></asp:MenuItem>
            </asp:MenuItem>
    </Items>
    <StaticHoverStyle BackColor="Silver" ForeColor="White" />
</asp:Menu>