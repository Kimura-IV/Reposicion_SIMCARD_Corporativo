CREATE SEQUENCE PORTA.SEQ_ID_SIM_CR
  minvalue 1
  maxvalue 9999999999999999999
  START WITH 1
  INCREMENT BY 1
  cache 20;
  
ALTER TABLE PORTA.CR_BITACORA_REPOSICION_SIM
  MODIFY id_sim_cr DEFAULT PORTA.SEQ_ID_SIM_CR.NEXTVAL;

CREATE TABLE PORTA.CR_BITACORA_REPOSICION_SIM (
    id_sim_cr NUMBER,
    id_sim_det NUMBER NOT NULL,
    id_simcard_pr NUMBER NOT NULL,
    origen VARCHAR2(20),
    estado VARCHAR2(10),
    respuesta_ws VARCHAR2(2000),
    Telefono VARCHAR2(20),
    Numero_Simcard VARCHAR2(20),
    Usuario VARCHAR2(50),
    Numero_admin VARCHAR2(20),
    fecha_programada DATE,
    usuario_registro VARCHAR2(15),
    fecha_registro DATE,
    usuario_modificacion VARCHAR2(15),
    fecha_modificacion DATE,
    CONSTRAINT pk_cr_bitacora_sim PRIMARY KEY (id_sim_cr)
);
