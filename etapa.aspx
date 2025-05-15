<%@ Page Language="VB"  debug="true" MaintainScrollPositionOnPostback="true" StylesheetTheme="White" %>


<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ import Namespace="System.Web.Mail" %>
<%@ Register Assembly="BusyBoxDotNet" Namespace="BusyBoxDotNet" TagPrefix="busyboxdotnet" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">


<script runat="server">
    
    Public conexion As conexiones = New conexiones
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If User.Identity.IsAuthenticated Then
            Dim strClientIP As String
            strClientIP = Request.UserHostAddress()
            ip.Value = strClientIP
            usuario.Value = User.Identity.Name
            If User.IsInRole("Administrador") Or User.IsInRole("APL Reposicion Sim") Then
                FormView1.Visible = True
                Panel1.Visible = True
                permiso.Visible = False
            Else
                permiso.Visible = True
                FormView1.Visible = False
                Panel1.Visible = False
            End If
        End If
    End Sub
         
    Protected Sub guardar_click(ByVal sender As Object, ByVal e As System.EventArgs)
        ds_consultar.Insert()
        Dim est As String = estado.SelectedValue
        Dim id_sim As String = Request.QueryString("id_sim")
        Dim fecha, nom, direccion, cta, observacion, mail, tram, num_repo, num_repo_v As String
        
        Dim re As SqlDataReader = conexion.traerDataReader("SELECT A.id_sim, A.fecha_ing, A.nom_cliente, A.cta_axis, A.direccion, A.observacion, B.mail, B.id_padre, A.num_repo, A.num_repo_v, C.correo, C.medio, C.num_admin from tbl_atv_reposicion_sim A INNER JOIN Tbl_atv_reposicion_sim_proceso B ON (B.id_padre=A.id_sim)INNER JOIN tbl_bitacora_ws_solicitud_sim C ON (C.id_sim=A.id_sim) WHERE B.id_proc= " & id_sim & "", 2)
        
        
        'Dim connectionString As String = "intr_callConnectionString"
        'Dim dbConnection As IDbConnection = New SqlClient.SqlConnection(connectionString)
        'Dim queryString As String = "SELECT A.id_sim, A.fecha_ing, A.nom_cliente, A.cta_axis, A.direccion, A.observacion, B.mail, B.id_padre from tbl_atv_reposicion_sim A INNER JOIN Tbl_atv_reposicion_sim_proceso B ON (B.id_padre=A.id_sim) WHERE B.id_proc= " & id_sim & ""


        'Dim dbCommand As IDbCommand = New SqlClient.SqlCommand
        'dbCommand.CommandText = queryString
        'dbCommand.Connection = dbConnection


        'dbConnection.Open()
        'Dim dataReader As IDataReader = dbCommand.ExecuteReader(CommandBehavior.CloseConnection)


        While re.Read()
            fecha = re("fecha_ing").ToString()
            nom = re("nom_cliente").ToString()
            cta = re("cta_axis").ToString()
            direccion = re("direccion").ToString()
            observacion = re("observacion").ToString()
            mail = re("mail").ToString()
            tram = re("id_padre").ToString()
            num_repo = re("num_repo").ToString()
            num_repo_v = re("num_repo_v").ToString()
            
            If ((est = "A") Or (est = "R")) Then
                
              '  Dim msgMail As System.Web.Mail.MailMessage = New Mail.MailMessage()


              '  msgMail.To = "pcobos@claro.com.ec"
               ' msgMail.From = "reposicion_simcard@claro.com.ec;"
                'msgMail.Subject = "Reposición de Simcard No. tramite: " & tram


              '  msgMail.BodyFormat = System.Web.Mail.MailFormat.Html
        
              '  Dim strBody As StringBuilder = New StringBuilder("")
         
               ' strBody.Append("<html><body><font face=Verdana, Arial, Helvetica, sans-serif size=2><b>Asesor Responsable: <font color=blue>" & Profile.Nombre & " " & Profile.Apellido & "</font></b>")
              '  strBody.Append("<br><b>Fecha del trámite: </b> " & fecha)
              '  strBody.Append("<br><b>Nombre del cliente: </b>" & nom)
              '  strBody.Append("<br><b>Cuenta Axis: </b>" & cta)
              '  strBody.Append("<br><b>Numero de Reposición: <font color=red>" & num_repo & "</font></b>")
              '  strBody.Append("<br><b>Numeros Adicionales: </b>" & num_repo_v)
              '  strBody.Append("<br><b>Dirección: </b>" & direccion)
              '  strBody.Append("<br><b>Observación: </b>" & observacion)
              '  strBody.Append("<br><b>Respuesta: </b>" & resp.Text)
              '  strBody.Append("<br><b>Estado Actual: <font color=red>" & estado.SelectedItem.Text & "</font></b>")
              '  strBody.Append("<br><br><b>Cualquier novedad sobre el trámite debe enviar un mail al asesor responsable.</b><br><br>")
              '  strBody.Append("</font></body></html>")
              '  msgMail.Body = strBody.ToString


             '   System.Web.Mail.SmtpMail.Send(msgMail)
            
            End If
            
            '8957 - INICIO - CIM GORTIZ - 14/07/2014 - Envio alerta error al cliente
            If (est = "R") Then
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
                
                Dim correo As String = ""
                Dim medio As String = ""
                Dim tipo_novedad As String = "SRSI"
                Dim destinatario As String = ""
                Dim telefono_administrador As String = ""


                destinatario = num_repo_v
                destinatario = destinatario.Replace(" ", "~")
        
                Try
                    correo = re("correo").ToString()
                    medio = re("medio").ToString()
                    telefono_administrador = re("num_admin").ToString()
                Catch ex As Exception
                End Try
        
                observacion = correo & "~" & id_sim & "~" & fecha & "~ERROR"
        
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
            End If
            '8957 - FIN - CIM GORTIZ - 14/07/2014 - Envio alerta error al cliente
        End While
            
        Response.Write("<script language=""javascript"">")
        Response.Write("window.opener.location.reload();")
        Response.Write("window.close() </")
        Response.Write("scrip")
        Response.Write("t>")
        
    End Sub
    
    Protected Sub FormView1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim es As String = DataBinder.Eval(FormView1.DataItem, "ultimo_estado")
        fecha_e.Text = DataBinder.Eval(FormView1.DataItem, "fecha_entrega").ToString
        sim.Text = DataBinder.Eval(FormView1.DataItem, "simcard").ToString
        sim_2.Text = DataBinder.Eval(FormView1.DataItem, "sim2").ToString
        sim_3.Text = DataBinder.Eval(FormView1.DataItem, "sim3").ToString
        sim_4.Text = DataBinder.Eval(FormView1.DataItem, "sim4").ToString
        sim_5.Text = DataBinder.Eval(FormView1.DataItem, "sim5").ToString
        sim_6.Text = DataBinder.Eval(FormView1.DataItem, "sim6").ToString
        sim_7.Text = DataBinder.Eval(FormView1.DataItem, "sim7").ToString
        sim_8.Text = DataBinder.Eval(FormView1.DataItem, "sim8").ToString
        sim_9.Text = DataBinder.Eval(FormView1.DataItem, "sim9").ToString
        sim_10.Text = DataBinder.Eval(FormView1.DataItem, "sim10").ToString
        hora_e1.Text = DataBinder.Eval(FormView1.DataItem, "hora_entrega").ToString
        hora_e2.Text = DataBinder.Eval(FormView1.DataItem, "min_entrega").ToString
        If es = "I" Then
            estado.Items.Clear()
            estado.Items.Add(New ListItem("Ingresado", "I"))
            estado.Items.Add(New ListItem("En Proceso", "P"))
            estado.Items.Add(New ListItem("Rechazado", "R"))
        ElseIf es = "P" Then
            estado.Items.Clear()
            estado.Items.Add(New ListItem("En Proceso", "P"))
            estado.Items.Add(New ListItem("Facturación", "F"))
        
        ElseIf es = "F" Then
            estado.Items.Clear()
            estado.Items.Add(New ListItem("En Proceso Entrega", "E"))


        ElseIf es = "E" Then
            estado.Items.Clear()
            estado.Items.Add(New ListItem("Activado", "A"))
        End If
    End Sub
</script>


<script language =javascript >


	//<![CDATA[
function validar_coment(source,arguments) { 
	
if ((arguments.Value.length==0)){
    alert("Por favor, ingrese alguna observación sobre el trámite.");
	arguments.IsValid=false;}
	else
	arguments.IsValid=true;
}
	
function mostrar_campo(obj){
    var   a=document.getElementById("sim1");
    var   b=document.getElementById("sim2");
    var   c=document.getElementById("hora1");
    var   d=document.getElementById("hora2");
    var   e=document.getElementById("fecha1");
    var   f=document.getElementById("fecha2");
    var   g=document.getElementById("sim3");
    var   h=document.getElementById("sim4");
    var   i=document.getElementById("sim5");
    var   j=document.getElementById("sim6");
    var   k=document.getElementById("sim7");
    var   l=document.getElementById("sim8");
    var   m=document.getElementById("sim9");
    var   n=document.getElementById("sim10");
    var   o=document.getElementById("sim11");
    var   p=document.getElementById("sim12");
    var   q=document.getElementById("sim13");
    var   r=document.getElementById("sim14");
    var   s=document.getElementById("sim15");
    var   t=document.getElementById("sim16");
    var   u=document.getElementById("sim17");
    var   v=document.getElementById("sim18");
    var   w=document.getElementById("sim19");
    var   x=document.getElementById("sim20");
    
    if ((obj.value=="I") || (obj.value=="F") || (obj.value=="E") || (obj.value=="A")){
        c.style.display="none"
        d.style.display="none"
        e.style.display="none"
        f.style.display="none"
    }    
    else {
        c.style.display="block"
        d.style.display="block"
        e.style.display="block"
        f.style.display="block"
    }
    
    if ((obj.value=="I") || (obj.value=="P") || (obj.value=="E") || (obj.value=="A")){
        a.style.display="none"
        b.style.display="none"
        g.style.display="none"
        h.style.display="none"
        i.style.display="none"
        j.style.display="none"
        k.style.display="none"
        l.style.display="none"
        m.style.display="none"
        n.style.display="none"
        o.style.display="none"
        p.style.display="none"
        q.style.display="none"
        r.style.display="none"
        s.style.display="none"
        t.style.display="none"
        u.style.display="none"
        v.style.display="none"
        w.style.display="none"
        x.style.display="none"
    }    
    else{
        a.style.display="block"
        b.style.display="block"
        g.style.display="block"
        h.style.display="block"
        i.style.display="block"
        j.style.display="block"
        k.style.display="block"
        l.style.display="block"
        m.style.display="block"
        n.style.display="block"
        o.style.display="block"
        p.style.display="block"
        q.style.display="block"
        r.style.display="block"
        s.style.display="block"
        t.style.display="block"
        u.style.display="block"
        v.style.display="block"
        w.style.display="block"
        x.style.display="block"
    }
 }	


//]]>


</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Reposición de Simcard | Consulta Detalle</title>
    <script language="javascript" src="/portalsco/include/js/calendar/popcalendar.js"></script>
    <LINK href="/portalsco/include/js/calendar/popcalendar.css" type="text/css" rel="stylesheet">        
</head>
<body leftmargin="0" rightmargin="0" topmargin="0">
    <form id="form1" runat="server">
        <table bgcolor="#e90505" cellpadding="0" cellspacing="0" style="text-align: center; width: 944px;">
            <tr>
                <td background="../../../images/apl/simcard.jpg" bgcolor="#e90505" style="text-align: right; height: 97px;"
                    width="553">
                    
                </td>
            </tr>
        </table>
        <br />
        <asp:FormView ID="FormView1" runat="server" DataSourceID="ds_consultar" Visible="False" DataKeyNames="id_sim" SkinID="porta" OnDataBound="FormView1_DataBound">
            <InsertItemTemplate>
                <br />
                &nbsp;
            </InsertItemTemplate>
            <ItemTemplate>
                    <table style="width: 450px" id="Table1">
                        <tr>
                            <td class="red" style="width: 105px; height: 15px;">
                                <span style="font-size: 9pt">ETAPA ACTUAL</span></td>
                            <td style="width: 345px; height: 15px;">
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 105px; height: 15px">
                                <strong><span style="color: #000000">
                                Estado Actual:</span></strong></td>
                            <td style="width: 345px; height: 15px">
                                <asp:Literal ID="Literal9" runat="server" Text='<%# eval("est") %>'></asp:Literal></td>
                        </tr>
                        <tr>
                            <td style="width: 105px; height: 15px">
                                <strong><span style="color: #000000">
                                Observación:</span></strong></td>
                            <td style="width: 345px; height: 15px">
                                <asp:Literal ID="Literal10" runat="server" Text='<%# eval("ultima_obs") %>'></asp:Literal></td>
                        </tr>
                        <tr>
                            <td style="width: 105px; height: 8px">
                            </td>
                            <td style="width: 345px; height: 8px">
                            </td>
                        </tr>
                       
                    </table>
       
            </ItemTemplate>
            </asp:FormView>
        <asp:Panel ID="Panel1" runat="server" Height="50px" Width="450px" Visible="False">
   
        <table style="width: 680px" id="Table2">
            <tr>
                <td style="width: 120px; height: 15px">
                    <strong><span style="color: #000000">
                    Respuesta:</span></strong></td>
                <td style="width: 330px; height: 15px">
                <asp:TextBox ID="resp" runat="server" Columns="45" MaxLength="500" Rows="7" 
                        TextMode="MultiLine" Width="300px" onKeypress="if ((event.keyCode > 0 && event.keyCode < 32)|| (event.keyCode > 33 && event.keyCode < 35) ||(event.keyCode > 38 && event.keyCode < 40) ||(event.keyCode > 95 && event.keyCode < 97) ||(event.keyCode > 125 && event.keyCode < 164) || (event.keyCode > 165 && event.keyCode < 256)) event.returnValue = false;"></asp:TextBox>
                    <asp:CustomValidator ID="CustomValidator4" runat="server" ClientValidationFunction="validar_coment"
                        ControlToValidate="resp" SetFocusOnError="True" ValidateEmptyText="True"></asp:CustomValidator></td>
            </tr>
            <tr style="color: #666666">
                <td class="atvblack" ID="fecha1" style="display :none ; width: 120px;">
                                           Fecha de Entrega Simcard:</td>
                <td ID="fecha2" style="display :none ; width: 330px;">
                 <asp:TextBox ID="fecha_e" runat="server" MaxLength="10" Width="70px"></asp:TextBox> <img id="Img1" align="absMiddle" alt="calendar" height="17" name="imgFi" onclick="popUpCalendar(this,fecha_e, 'dd/mm/yyyy');"
                                    src="../../../images/apl/calendario.gif" style="cursor: hand" width="22" />                              
                    </td>
            </tr>
            <tr style="color: #666666">
                <td class="atvblack" ID="hora1" style="display :none ; width: 120px;">
                    Hora de Entrega Simcard:</td>
                <td ID="hora2" style="display :none ; width: 330px;">
                <asp:TextBox ID="hora_e1" runat="server" MaxLength="2" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="20px"></asp:TextBox><b>:</b><asp:TextBox ID="hora_e2" runat="server" MaxLength="2" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="20px"></asp:TextBox></td>
            </tr>
            <tr style="color: #666666">
                <td class="atvblack" ID="sim1" style="display :none ; width: 120px;">
                    No. Simcard 1:</td>
                <td ID="sim2" style="display :none ; width: 330px;">
                <asp:TextBox ID="sim" runat="server" MaxLength="18" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="140px"></asp:TextBox>
                </td>
                <td class="atvblack" ID="sim11" style="display :none ; width: 120px;">
                    No. Simcard 6:</td>
                <td ID="sim12" style="display :none ; width: 150px;">
                <asp:TextBox ID="sim_6" runat="server" MaxLength="18" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="140px">-</asp:TextBox>
                </td>
            </tr>
            <tr style="color: #666666">
                <td class="atvblack" ID="sim3" style="display :none ; width: 120px;">
                    No. Simcard 2:</td>
                <td ID="sim4" style="display :none ; width: 330px;">
                <asp:TextBox ID="sim_2" runat="server" MaxLength="18" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="140px">-</asp:TextBox>
                </td>
                <td class="atvblack" ID="sim13" style="display :none ; width: 120px;">
                    No. Simcard 7:</td>
                <td ID="sim14" style="display :none ; width: 150px;">
                <asp:TextBox ID="sim_7" runat="server" MaxLength="18" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="140px">-</asp:TextBox>
                </td>
            </tr>
            <tr style="color: #666666">
                <td class="atvblack" ID="sim5" style="display :none ; width: 120px;">
                    No. Simcard 3:</td>
                <td ID="sim6" style="display :none ; width: 330px;">
                <asp:TextBox ID="sim_3" runat="server" MaxLength="18" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="140px">-</asp:TextBox>
                </td>
                 <td class="atvblack" ID="sim15" style="display :none ; width: 120px;">
                    No. Simcard 8:</td>
                <td ID="sim16" style="display :none ; width: 150px;">
                <asp:TextBox ID="sim_8" runat="server" MaxLength="18" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="140px">-</asp:TextBox>
                </td>
            </tr>
            <tr style="color: #666666">
                <td class="atvblack" ID="sim7" style="display :none ; width: 120px;">
                    No. Simcard 4:</td>
                <td ID="sim8" style="display :none ; width: 330px;">
                <asp:TextBox ID="sim_4" runat="server" MaxLength="18" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="140px">-</asp:TextBox>
                </td>
                <td class="atvblack" ID="sim17" style="display :none ; width: 120px;">
                    No. Simcard 9:</td>
                <td ID="sim18" style="display :none ; width: 150px;">
                <asp:TextBox ID="sim_9" runat="server" MaxLength="18" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="140px">-</asp:TextBox>
                </td>
            </tr>
            <tr style="color: #666666">
                <td class="atvblack" ID="sim9" style="display :none ; width: 120px;">
                    No. Simcard 5:</td>
                <td ID="sim10" style="display :none ; width: 330px;">
                <asp:TextBox ID="sim_5" runat="server" MaxLength="18" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="140px">-</asp:TextBox>
                </td>
                <td class="atvblack" ID="sim19" style="display :none ; width: 120px;">
                    No. Simcard 10:</td>
                <td ID="sim20" style="display :none ; width: 150px;">
                <asp:TextBox ID="sim_10" runat="server" MaxLength="18" onkeypress="if ((event.keyCode > 0 && event.keyCode < 48)|| (event.keyCode > 57 && event.keyCode < 256)) event.returnValue = false;"
                                    Width="140px">-</asp:TextBox>
                </td>
            </tr>
            <tr>
                <td style="width: 120px; height: 15px">
                    <strong><span style="color: #000000">
                    Estado:</span></strong></td>
                <td style="width: 330px; height: 15px">
                    <asp:DropDownList ID="estado" runat="server" onchange="mostrar_campo(this)">
                        <asp:ListItem Value="P">En Proceso</asp:ListItem>
                        <asp:ListItem Value="F">Facturaci&#243;n</asp:ListItem>
                        <asp:ListItem Value="E">En Proceso Entrega</asp:ListItem>
                        <asp:ListItem Value="A">Activado</asp:ListItem>
                    </asp:DropDownList></td>
            </tr>
        </table>
        </asp:Panel>
        <br />
        <br />
                    <asp:Button ID="guardar" runat="server" Text="Actualizar" OnClick="guardar_click" Font-Bold="True" /><asp:SqlDataSource ID="ds_consultar" runat="server" ConnectionString="<%$ ConnectionStrings:Intr_callConnectionString %>"
                SelectCommand="atv_reposicion_etapa" InsertCommand="atv_reposicion_sim_act" InsertCommandType="StoredProcedure" SelectCommandType="StoredProcedure" >
            <SelectParameters>
                <asp:QueryStringParameter Name="id_sim" QueryStringField="id_sim" />
                <asp:Parameter Direction="ReturnValue" Name="RETURN_VALUE" Type="Int32" />
            </SelectParameters>
                <InsertParameters>
                    <asp:QueryStringParameter Name="id" QueryStringField="id_sim" Type="Int32" />
                    <asp:ControlParameter ControlID="resp" Name="respuesta" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="usuario" Name="login" PropertyName="Value" Type="String" />
                    <asp:ControlParameter ControlID="ip" Name="ip" PropertyName="Value" Type="String" />
                    <asp:ControlParameter ControlID="estado" Name="estado" PropertyName="SelectedValue"
                        Type="String" />
                    <asp:ControlParameter ControlID="fecha_e" Name="fecha" PropertyName="Text" Type="DateTime" />
                    <asp:ControlParameter ControlID="hora_e1" Name="hora1" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="hora_e2" Name="hora2" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="sim" Name="sim1" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="sim_2" Name="sim2" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="sim_3" Name="sim3" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="sim_4" Name="sim4" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="sim_5" Name="sim5" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="sim_6" Name="sim6" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="sim_7" Name="sim7" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="sim_8" Name="sim8" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="sim_9" Name="sim9" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="sim_10" Name="sim10" PropertyName="Text" Type="String" />
                    
                </InsertParameters>
            </asp:SqlDataSource>
        <busyboxdotnet:busybox id="BusyBox1" runat="server" slideduration="900" text="Por favor espere mientras se procesan los datos."
            title="Portal SCO"></busyboxdotnet:busybox>
        <asp:HiddenField ID="ip" runat="server" />
        <asp:HiddenField ID="usuario" runat="server" />
            <asp:Label ID="permiso" runat="server" Text="Usted no es usuario autorizado para el acceso a este aplicativo, comuniquese con su supervisor o el Administrador del Portal SCO."
            Visible="False" Font-Bold="True"></asp:Label>
        
    </form>
</body>
</html>
