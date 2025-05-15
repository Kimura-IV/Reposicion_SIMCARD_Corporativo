CREATE OR REPLACE PACKAGE PORTA.CLK_REPOSICION_SIM_EN_LINEA IS

  --procedimiento para insertar registros en la cola
  PROCEDURE P_INSERTAR_BITACORA_SIM(PN_ID_SIM_DET     IN NUMBER,
                                    PN_ID_SIMCARD_PR  IN NUMBER,
                                    PV_ORIGEN         IN VARCHAR2,
                                    PV_ESTADO         IN VARCHAR2,
                                    PV_TELEFONO       IN VARCHAR2,
                                    PV_NUMERO_SIMCARD IN VARCHAR2,
                                    PV_USUARIO        IN VARCHAR2,
                                    PV_NUMERO_ADMIN   IN VARCHAR2,
                                    PN_ERROR          OUT NUMBER,
                                    PV_ERROR          OUT VARCHAR2);

  --procedimiento para actualizar registros por id de solicitud
  PROCEDURE P_ACTUALIZA_BITACORA_SIM(PN_ID_SIMCARD_PR IN NUMBER,
                                     PV_ESTADO        IN VARCHAR2,
                                     PN_ERROR         OUT NUMBER,
                                     PV_ERROR         OUT VARCHAR2);

  --procedimiento para despachar registros pendientes de la cola
  PROCEDURE P_REPONE_COLA_EN_LINEA;

END CLK_REPOSICION_SIM_EN_LINEA;
/
CREATE OR REPLACE PACKAGE BODY PORTA.CLK_REPOSICION_SIM_EN_LINEA IS

  PROCEDURE P_INSERTAR_BITACORA_SIM(PN_ID_SIM_DET     IN NUMBER,
                                    PN_ID_SIMCARD_PR  IN NUMBER,
                                    PV_ORIGEN         IN VARCHAR2,
                                    PV_ESTADO         IN VARCHAR2,
                                    PV_TELEFONO       IN VARCHAR2,
                                    PV_NUMERO_SIMCARD IN VARCHAR2,
                                    PV_USUARIO        IN VARCHAR2,
                                    PV_NUMERO_ADMIN   IN VARCHAR2,
                                    PN_ERROR          OUT NUMBER,
                                    PV_ERROR          OUT VARCHAR2)
  
   IS
  
    LN_ID_REGISTRO    NUMBER;
    LD_FEC_REGISTRO   DATE;
    LD_FEC_PROGRAMADA DATE;
    LN_MINUTOS        NUMBER;
  
  BEGIN
  
    --obtiene minutos de espera
    BEGIN
      LN_MINUTOS := TO_NUMBER(PORTA.GVK_PARAMETROS_GENERALES.GVF_OBTENER_VALOR_PARAMETRO(22735,
                                                                                         'PN_MINUTOS_ESPERA'));
    EXCEPTION
      WHEN OTHERS THEN
        LN_MINUTOS := 30;
    END;
  
    --secuencial de la tabla
    SELECT PORTA.CL_SEQ_BITACORA_REPO_SIM.NEXTVAL
      INTO LN_ID_REGISTRO
      FROM DUAL;
  
    --obtiene fecha programada sumando minutos a la fecha de registro
    SELECT SYSDATE, SYSDATE + (1 / 1440 * LN_MINUTOS)
      INTO LD_FEC_REGISTRO, LD_FEC_PROGRAMADA
      FROM DUAL;
  
    --registro
    INSERT INTO PORTA.CL_BITACORA_REPOSICION_SIM
      (ID_SIM_COLA,
       ID_SIM_DET,
       ID_SIMCARD_PR,
       ORIGEN,
       ESTADO,
       TELEFONO,
       NUMERO_SIMCARD,
       USUARIO,
       NUMERO_ADMIN,
       FECHA_PROGRAMADA,
       USUARIO_REGISTRO,
       FECHA_REGISTRO)
    VALUES
      (LN_ID_REGISTRO,
       PN_ID_SIM_DET,
       PN_ID_SIMCARD_PR,
       PV_ORIGEN,
       PV_ESTADO,
       PV_TELEFONO,
       PV_NUMERO_SIMCARD,
       PV_USUARIO,
       PV_NUMERO_ADMIN,
       LD_FEC_PROGRAMADA,
       USER,
       LD_FEC_REGISTRO);
    COMMIT;
  
    PN_ERROR := 0;
    PV_ERROR := NULL;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      PN_ERROR := SQLCODE;
      PV_ERROR := SQLERRM;
    
  END;

  PROCEDURE P_ACTUALIZA_BITACORA_SIM(PN_ID_SIMCARD_PR IN NUMBER,
                                     PV_ESTADO        IN VARCHAR2,
                                     PN_ERROR         OUT NUMBER,
                                     PV_ERROR         OUT VARCHAR2)
  
   IS
  
    LV_ESTADOP VARCHAR2(10) := 'PENDIENTE';
  
  BEGIN
  
    --actualiza registros pendientes
    UPDATE PORTA.CL_BITACORA_REPOSICION_SIM J
       SET J.ESTADO               = PV_ESTADO,
           J.USUARIO_MODIFICACION = USER,
           J.FECHA_MODIFICACION   = SYSDATE
     WHERE J.ID_SIMCARD_PR = PN_ID_SIMCARD_PR
       AND J.ESTADO = LV_ESTADOP;
  
    COMMIT;
  
    PN_ERROR := 0;
    PV_ERROR := NULL;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      PN_ERROR := SQLCODE;
      PV_ERROR := SQLERRM;
    
  END;

  PROCEDURE P_REPONE_COLA_EN_LINEA IS
  
    CURSOR C_REPONE_PENDIENTE IS
      SELECT G.ID_SIM_COLA,
             G.ID_SIMCARD_PR,
             G.ID_SIM_DET,
             G.TELEFONO,
             G.NUMERO_SIMCARD,
             G.USUARIO,
             G.NUMERO_ADMIN
        FROM PORTA.CL_BITACORA_REPOSICION_SIM G
       WHERE G.ESTADO = 'PENDIENTE'
         AND G.FECHA_PROGRAMADA > SYSDATE
       ORDER BY G.ID_SIMCARD_PR, G.ID_SIM_DET;
  
    TYPE LR_DATOS IS TABLE OF C_REPONE_PENDIENTE%ROWTYPE INDEX BY PLS_INTEGER;
    LT_DATOS LR_DATOS;
  
    LV_CONFIRMA       VARCHAR2(1000);
    LV_MENSAJETECNICO VARCHAR2(1000);
    LV_MENSAJEUSUARIO VARCHAR2(1000);
    LN_CODIGO_ERROR   NUMBER;
    LV_BANDERA_SP     VARCHAR2(10);
    LN_REGISTROS      NUMBER;
    LV_ESTADOE        VARCHAR2(10) := 'EXITO';
    LV_ESTADOF        VARCHAR2(10) := 'FALLO';
    LV_PROGRAMA       VARCHAR2(60) := 'PORTA.CLK_REPOSICION_SIM_EN_LINEA.P_REPONE_COLA_EN_LINEA';
  
  BEGIN
  
    DBMS_OUTPUT.PUT_LINE('Inicio de Ejecucion de ' || LV_PROGRAMA ||
                         '. Fecha: ' ||
                         TO_CHAR(SYSDATE, 'DDMMYYYY HH24:MI:SS'));
  
    --obtiene bandera de ejecucion
    LV_BANDERA_SP := NVL(PORTA.GVK_PARAMETROS_GENERALES.GVF_OBTENER_VALOR_PARAMETRO(22735,
                                                                                    'GV_EJECUCION_SP_REPOSICION'),
                         'N');
  
    --obtiene numero de registros a procesar
    BEGIN
      LN_REGISTROS := TO_NUMBER(PORTA.GVK_PARAMETROS_GENERALES.GVF_OBTENER_VALOR_PARAMETRO(22735,
                                                                                           'PN_REGISTROS_PROCESAR'));
    EXCEPTION
      WHEN OTHERS THEN
        LN_REGISTROS := 50;
    END;
  
    --obtiene registros pendientes
    OPEN C_REPONE_PENDIENTE;
  
    LOOP
      --almacenan registros en coleccion
      FETCH C_REPONE_PENDIENTE BULK COLLECT
        INTO LT_DATOS LIMIT LN_REGISTROS;
      EXIT WHEN LT_DATOS.COUNT = 0;
    
      FOR I IN LT_DATOS.FIRST .. LT_DATOS.LAST LOOP
      
        LV_CONFIRMA       := NULL;
        LV_MENSAJETECNICO := NULL;
        LV_MENSAJEUSUARIO := NULL;
        LN_CODIGO_ERROR   := NULL;
      
        IF LV_BANDERA_SP = 'S' THEN
        
          --se ejecuta proceso de reposicion
          PORTA.PRC_REPOSICIONSIMCARD_MICLARO(LT_DATOS         (I).TELEFONO,
                                              LT_DATOS         (I).NUMERO_SIMCARD,
                                              LT_DATOS         (I).USUARIO,
                                              LT_DATOS         (I).NUMERO_ADMIN,
                                              LV_CONFIRMA,
                                              LV_MENSAJETECNICO,
                                              LV_MENSAJEUSUARIO,
                                              LN_CODIGO_ERROR);
        
          IF NVL(LV_CONFIRMA, 'X') = 'S' THEN
          
            --se actualiza por exito
            UPDATE PORTA.CL_BITACORA_REPOSICION_SIM L
               SET L.ESTADO               = LV_ESTADOE,
                   L.RESPUESTA            = LV_MENSAJEUSUARIO,
                   L.USUARIO_MODIFICACION = USER,
                   L.FECHA_MODIFICACION   = SYSDATE
             WHERE L.ID_SIM_COLA = LT_DATOS(I).ID_SIM_COLA;
            COMMIT;
          
          ELSIF NVL(LV_CONFIRMA, 'X') = 'N' THEN
          
            --se actualiza por error
            UPDATE PORTA.CL_BITACORA_REPOSICION_SIM L
               SET L.ESTADO               = LV_ESTADOF,
                   L.RESPUESTA            = LV_MENSAJETECNICO,
                   L.USUARIO_MODIFICACION = USER,
                   L.FECHA_MODIFICACION   = SYSDATE
             WHERE L.ID_SIM_COLA = LT_DATOS(I).ID_SIM_COLA;
            COMMIT;
          
          END IF;
        
        END IF;
      
      END LOOP;
    
    END LOOP;
    CLOSE C_REPONE_PENDIENTE;
  
    DBMS_OUTPUT.PUT_LINE('Fin de Ejecucion de ' || LV_PROGRAMA ||
                         '. Fecha: ' ||
                         TO_CHAR(SYSDATE, 'DDMMYYYY HH24:MI:SS'));
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('Error Inesperado en la Ejecucion de ' ||
                           LV_PROGRAMA || '. Fecha: ' ||
                           TO_CHAR(SYSDATE, 'DDMMYYYY HH24:MI:SS'));
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
      DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
      DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  END;

END;
/
