CREATE OR REPLACE PACKAGE Porta AS
    PROCEDURE clk_reposicion_sim_en_linea(p_id_simcard_pr IN NUMBER, pn_error OUT NUMBER, pv_error OUT VARCHAR2);
END Porta;
/

CREATE OR REPLACE PACKAGE BODY Porta AS
    PROCEDURE clk_reposicion_sim_en_linea(p_id_simcard_pr IN NUMBER, pn_error OUT NUMBER, pv_error OUT VARCHAR2) IS
    BEGIN
        pn_error := 0;
        pv_error := NULL;
           
        UPDATE Cl_bitacora_reposicion_sim J
        SET J.ESTADO = 'CANCELADO'
        WHERE J.id_simcard_pr = p_id_simcard_pr AND J.ESTADO = 'P';
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            pn_error := SQLCODE;
            pv_error := SQLERRM;
    END clk_reposicion_sim_en_linea;
END Porta;
/

UPDATE CR_BITACORA_REPOSICION_SIM J
SET J.ESTADO = 'CANCELADO'
where J.id_simcard_pr = (PARAMETRO QUE LLEGA) AND J.ESTADO = 'P';
COMMIT;

/***************************************************/

PROCEDURE P_REPOSICION_COLA IS

CURSOR C_DATOS_PENDIENTES IS
SELECT * FROM CR_BITACORA_REPOSICION_SIM T
WHERE T.ESTADO = 'PENDIENTE'
AND T.FECHA_PROGRAMADA > SYSDATE;

BEGIN

FOR T IN C_DATOS_PENDIENTES;
PORTA.PRC_REPOSICIONSIMCARD_MICLARO();

IF LN_RESPUESTA = 0 THEN
UPDATE CR_BITACORA_REPOSICION_SIM P
SET J.ESTADO = 'EXITO';
ELSE

MENSAJE DE ERROR

END LOOP;

END;
