PL/SQL Developer Test script 3.0
16
begin
  -- Call the procedure
  porta.P_insertar_bitacora_sim(pn_id_sim_det => :pn_id_sim_det,
                                pn_id_simcard_pr => :pn_id_simcard_pr,
                                pv_origen => :pv_origen,
                                pv_estado => :pv_estado,
                                pv_respuesta_ws => :pv_respuesta_ws,
                                pv_telefono => :pv_telefono,
                                pv_numero_simcard => :pv_numero_simcard,
                                pv_usuario => :pv_usuario,
                                pv_numero_admin => :pv_numero_admin,
                                pn_fecha_programada => :pn_fecha_programada,
                                pv_usuario_registro => :pv_usuario_registro,
                                pn_error => :pn_error,
                                pv_error => :pv_error);
end;
13
pn_id_sim_det
1
1
4
pn_id_simcard_pr
1
1
4
pv_origen
1
GYE
5
pv_estado
1
ON
5
pv_respuesta_ws
1
PRUEBA
5
pv_telefono
1
0999999999
5
pv_numero_simcard
1
0999999999
5
pv_usuario
1
PRUEBA
5
pv_numero_admin
1
0999999999
5
pn_fecha_programada
1
10/08/2023
12
pv_usuario_registro
1
PRUEBAUSUARIO
5
pn_error
1
0
4
pv_error
0
5
0
