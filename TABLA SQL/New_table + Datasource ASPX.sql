/* TABLA NUEVA EN SQL SERVER */

[martes 11:57] TIC Luis Flores
script para pase a prod de la tabla
[martes 11:57] TIC Luis Flores
USE [Intr_call]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tbl_atv_reposision_sim_cola](
    [id_simcard_cola] [int] IDENTITY(1,1) NOT NULL,
    [id_simcard_pr] [int] NOT NULL,
    [origen] [nchar](20) NULL,
    [estado] [nchar](10) NULL,
    [respuesta_ws] [nvarchar](max) NULL,
    [fecha_programada] [datetime] NULL,
    [usuario_registro] [nchar](15) NULL,
    [fecha_registro] [datetime] NULL,
    [usuario_modificacion] [nchar](15) NULL,
    [fecha_modificacion] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/* DATASOURCE */

<asp:SqlDataSource ID="ds_guardar_cola" runat="server" ConnectionString="<%$ ConnectionStrings:TuConnectionString %>"
    InsertCommand="INSERT INTO Tbl_atv_reposision_sim_cola
    (id_simcard_cola, id_simcard_pr, origen, estado, respuesta_ws, fecha_programada, usuario_registro, fecha_registro, usuario_modificacion, fecha_modificacion)
    VALUES
    (SCOPE_IDENTITY(), @id_simcard_pr, @origen, @estado, @respuesta_ws, @fecha_programada, @usuario_registro, @fecha_registro, @usuario_modificacion, @fecha_modificacion);">
    <InsertParameters>
        <asp:ControlParameter Name="id_simcard_pr" />
        <asp:ControlParameter Name="origen" />
        <asp:ControlParameter Name="estado" />
        <asp:ControlParameter Name="respuesta_ws" />
        <asp:ControlParameter Name="fecha_programada" />
        <asp:ControlParameter Name="usuario_registro" />
        <asp:ControlParameter Name="fecha_registro" />
        <asp:ControlParameter Name="usuario_modificacion" />
        <asp:ControlParameter Name="fecha_modificacion" />
    </InsertParameters>
</asp:SqlDataSource>
<busyboxdotnet:busybox id="BusyBox2" runat="server" slideduration="900" text="Por favor espere mientras se procesan los datos." title="Portal SCO" />
&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
