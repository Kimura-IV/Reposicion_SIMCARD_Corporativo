CREATE PROCEDURE CambiarEstado
AS
BEGIN
    DECLARE @HoraActual DATETIME;
    SET @HoraActual = GETDATE();
    
    -- Actualizar la tabla Tbl_atv_reposicion_sim_proceso
    UPDATE Intr_call.Tbl_atv_reposicion_sim_proceso
    SET estado = 'I'
    WHERE estado = 'X'
    AND EXISTS (
        SELECT 1
        FROM Intr_call.Tbl_atv_reposision_sim_cola c
        WHERE c.id_simcard_pr = Tbl_atv_reposicion_sim_proceso.id_padre
        AND c.estado = 'PENDIENTE'
        AND c.fecha_programada > @HoraActual
    );
    
    -- Actualizar la tabla Tbl_atv_reposicion_sim_cola
    UPDATE Intr_call.Tbl_atv_reposision_sim_cola
    SET estado = 'FINALIZADO',
        fecha_modificacion = @HoraActual
    WHERE estado = 'PENDIENTE'
    AND fecha_programada > @HoraActual;
    
END;
