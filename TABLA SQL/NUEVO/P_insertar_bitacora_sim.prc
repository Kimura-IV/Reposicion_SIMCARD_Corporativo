CREATE OR REPLACE PROCEDURE PORTA.P_insertar_bitacora_sim (
    pn_id_sim_det NUMBER,
    pn_id_simcard_pr NUMBER,
    pv_origen VARCHAR2,
    pv_estado VARCHAR2,
    pv_respuesta_ws VARCHAR2,
    pv_telefono VARCHAR2,
    pv_numero_simcard VARCHAR2,
    pv_usuario VARCHAR2,
    pv_numero_admin VARCHAR2,
    pn_fecha_programada DATE,
    pv_usuario_registro VARCHAR2,
    pn_error OUT NUMBER,
    pv_error OUT VARCHAR2
) AS
    v_id_sim_cr NUMBER;
BEGIN
    pn_error := 0;
    pv_error := '';

    SELECT PORTA.SEQ_ID_SIM_CR.NEXTVAL INTO v_id_sim_cr FROM dual;

    INSERT INTO porta.CR_BITACORA_REPOSICION_SIM (
        id_sim_cr,
        id_sim_det,
        id_simcard_pr,
        origen,
        estado,
        respuesta_ws,
        Telefono,
        Numero_Simcard,
        Usuario,
        Numero_admin,
        fecha_programada,
        usuario_registro,
        fecha_registro
    ) VALUES (
        v_id_sim_cr,
        pn_id_sim_det,
        pn_id_simcard_pr,
        pv_origen,
        pv_estado,
        pv_respuesta_ws,
        pv_telefono,
        pv_numero_simcard,
        pv_usuario,
        pv_numero_admin,
        pn_fecha_programada,
        pv_usuario_registro,
        SYSDATE
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Registro insertado correctamente. ID_SIM_CR: ' || v_id_sim_cr);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        pn_error := SQLCODE;
        pv_error := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('Error al insertar el registro: ' || pv_error);
END P_insertar_bitacora_sim;
/
