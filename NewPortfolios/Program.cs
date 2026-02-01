//Ejecuta scripts en el orden correcto
using Microsoft.Data.SqlClient;
using System.Transactions;
//return; //prevenir ejecución accidental
string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SIPLAConnectionString"].ToString();
using (TransactionScope scope = new TransactionScope())
{
    SqlConnection conn = new SqlConnection(connStr);
    SqlCommand comm = conn.CreateCommand();
    comm.CommandType = System.Data.CommandType.Text;
    conn.Open();

    comm.CommandType = System.Data.CommandType.Text;
    
    //commandos

    //30-dic-2025
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.TotalRecuperacionesView'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("TotalRecuperacionesView", "View", suffix: false);
    comm.ExecuteNonQuery();

    //26-ene-2026
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.EventoPortafolioAprox'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("EventoPortafolioAprox", "View", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = (new GetObjectCode()).GetCode("LIQUIDEZ_CACHE", "Change Script", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.PrepararLiquidezCache'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("PrepararLiquidezCache", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerDetallePortafolioConLiquidezView'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerDetallePortafolioConLiquidezView", "View", suffix: false);
    comm.ExecuteNonQuery();

    //27-ene-2026
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerDetallePortafolioConLiquidez'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerDetallePortafolioConLiquidez", "StoredProcedure", suffix: false);
    comm.ExecuteNonQuery();
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ESTRUCTURA_ISSPOL_G04'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ESTRUCTURA_ISSPOL_G04", "Change Script", suffix: false);
    comm.ExecuteNonQuery();
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ESTRUCTURA_ISSPOL_G05'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ESTRUCTURA_ISSPOL_G05", "Change Script", suffix: false);
    comm.ExecuteNonQuery();
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerEstructuraIsspolG04'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerEstructuraIsspolG04", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerEstructuraIsspolG05'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerEstructuraIsspolG05", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("LIQUIDEZ_CACHE", "Change Script", suffix: false);
    comm.ExecuteNonQuery();
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.LiqIntProv'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("LiqIntProv", "View", suffix: false);
    comm.ExecuteNonQuery();
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ComprobanteIsspolRubros'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ComprobanteIsspolRubros", "View", suffix: false);
    comm.ExecuteNonQuery();

    //G03
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.VALORACION_SB'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("VALORACION_SB", "Change Script", suffix: false);
    comm.ExecuteNonQuery();
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.GenerarValoracionSB'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("GenerarValoracionSB", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerEstructuraIsspolG03'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerEstructuraIsspolG03", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    //1-feb-2026
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerSaldoYDetallePortafolio'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerSaldoYDetallePortafolio", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerTodosSaldoYDetallePortafolio'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerTodosSaldoYDetallePortafolio", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.InsertarTituloPortafolio'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("InsertarTituloPortafolio", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ActualizarTituloPortafolio'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ActualizarTituloPortafolio", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    //fin comandos

    conn.Close();
    scope.Complete();
    return;
    
    comm.CommandText = (new GetObjectCode()).GetCode("Campos de evento_portafolio", "Change Script", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerDetallePortafolioConLiquidezView'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerDetallePortafolioConLiquidezView", "View", suffix:false);
    comm.ExecuteNonQuery();

    comm.CommandText = (new GetObjectCode()).GetCode("EvtTemp", "Change Script", suffix:false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerDetallePortafolioConLiquidez'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerDetallePortafolioConLiquidez", "StoredProcedure", suffix:false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.InsertarLiquidezPortafolio'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("BVQ_BACKOFFICE.InsertarLiquidezPortafolio", "StoredProcedure");
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.InsertarLiquidezTitulo'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("InsertarLiquidezTitulo", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.LiqIntProv'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("LiqIntProv", "View", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ComprobanteIsspolRubros'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ComprobanteIsspolRubros", "View", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ComprobanteIsspol'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ComprobanteIsspol", "View", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = (new GetObjectCode()).GetCode("COMPROBANTE_ISSPOL", "Change Script", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.GenerarComprobanteIsspol'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("GenerarComprobanteIsspol", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.IsspolComprobanteRecuperacion'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("IsspolComprobanteRecuperacion", "siisspolweb", suffix: false, plural:false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerEnvioRecuperacionISSPOL'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerEnvioRecuperacionISSPOL", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerConfAsientoRecuperacion'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerConfAsientoRecuperacion", "siisspolweb", suffix: false, plural: false);
    comm.ExecuteNonQuery();

    conn.Close();
    scope.Complete();
    return;
    /*
        #region dematerialize titulo_flujo_comun
        comm.CommandText = "dropifexists 'BVQ_ADMINISTRACION.TITULO_FLUJO_COMUN'";
        comm.ExecuteNonQuery();

        comm.CommandText = "dropifexists 'BVQ_ADMINISTRACION.TITULO_FLUJO_COMUN_RAW'";
        comm.ExecuteNonQuery();
        if (true)
        {
            comm.CommandText = (new TablaTituloFlujoComunRaw()).GetCode();
            comm.ExecuteNonQuery();

            comm.CommandText = (new titulo_flujo_comun()).GetCode();
            comm.ExecuteNonQuery();

            comm.CommandText = "dropifexists 'BVQ_ADMINISTRACION.GenerarTituloFlujoComun'";
            comm.ExecuteNonQuery();
            comm.CommandText = (new GetObjectCode()).GetCode("GenerarTituloFlujoComun", "StoredProcedure", false);
            comm.ExecuteNonQuery();
        }
        else
        {
            comm.CommandText = (new TablaTituloFlujoComun()).GetCode();
            comm.ExecuteNonQuery();
        }
        #endregion

        comm.CommandText = "dropifexists 'BVQ_ADMINISTRACION.TituloFlujoComun'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new GetObjectCode()).GetCode("BVQ_ADMINISTRACION.TituloFlujoComun", "View");
        comm.ExecuteNonQuery();

        comm.CommandText = (new GetObjectCode()).GetCode("RETR_CAPITAL y RETR_INTERES", "Change Script", suffix: false);
        comm.ExecuteNonQuery();
        ChangeScript(comm,"TPO_F1");
        comm.ExecuteNonQuery();
    */
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.HtpCupon'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("BVQ_BACKOFFICE.HtpCupon", "View");
    comm.ExecuteNonQuery();
    /*
    comm.CommandText = (new CamposParaGcvf()).GetCode();
    comm.ExecuteNonQuery();*/

    comm.CommandText = (new GetObjectCode()).GetCode("Campos prov compra_venta_flujo", "Change Script", suffix: false);
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("Campos prov liquidez_cache", "Change Script", suffix: false);
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("Campos prov evtTemp", "Change Script", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = (new GetObjectCode()).GetCode("Campos de evento_portafolio", "Change Script", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = (new GetObjectCode()).GetCode("LIQUIDEZ_CACHE", "Change Script", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = (new GetObjectCode()).GetCode("EvtTemp", "Change Script", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = (new GetObjectCode()).GetCode("COMPROBANTE_ISSPOL", "Change Script", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = (new GetObjectCode()).GetCode("USO_FONDOS", "Change Script", suffix: false);
    //comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.GenerarCompraVentaFlujo'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GenerarCompraVentaFlujo()).GetCode();
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.CompraVentaFlujo'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new CompraVentaFlujo()).GetCode();
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.EventoPortafolioAprox'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("BVQ_BACKOFFICE.EventoPortafolioAprox", "View");
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.EventoPortafolio'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("EventoPortafolio", "View", suffix: false);
    comm.ExecuteNonQuery();
    
        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.EventoPortafolioCorte'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new EventoPortafolioCorte()).GetCode();
        comm.ExecuteNonQuery();
    /*
        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ISSPOL_PROGS'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new ISSPOL_PROGS()).GetCode();
        comm.ExecuteNonQuery();
    */
        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.PortafolioCorte'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new GetObjectCode()).GetCode("BVQ_BACKOFFICE.PortafolioCorte", "View");
        comm.ExecuteNonQuery();
    
        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerInfoPortfoliosPorFecha'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new ObtenerInfoPortfoliosPorFecha()).GetCode();
        comm.ExecuteNonQuery();
    /*
        comm.CommandText = (new GetObjectCode()).GetCode("Campo TIV_ID en LIQUIDEZ_CACHE y evtTemp", "Change Script", suffix: false);
        comm.ExecuteNonQuery();

        comm.CommandText = (new GetObjectCode()).GetCode("Campo dias_cupon y TIV_FECHA_EMISION en LIQUIDEZ_CACHE y evtTemp", "Change Script", suffix: false);
        comm.ExecuteNonQuery();
    */
    comm.CommandText = (new GetObjectCode()).GetCode("Campos de evento_portafolio", "Change Script", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.PrepararLiquidezCache'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("PrepararLiquidezCache", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerDetallePortafolioConLiquidezView'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerDetallePortafolioConLiquidezView", "View", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerDetallePortafolioConLiquidez'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerDetallePortafolioConLiquidez", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.LiqIntProv'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("LiqIntProv", "View", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ComprobanteIsspolRubros'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ComprobanteIsspolRubros", "View", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ComprobanteIsspol'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ComprobanteIsspol", "View", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerComprobanteIsspol'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerComprobanteIsspol", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.GenerarComprobanteIsspol'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("GenerarComprobanteIsspol", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    /*
        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.InsertarTituloPortafolio'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new InsertarTituloPortafolio()).GetCode();
        comm.ExecuteNonQuery();
    */

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.InsertarLiquidezPortafolio'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new InsertarLiquidezPortafolio()).GetCode();
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.InsertarLiquidezTitulo'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("InsertarLiquidezTitulo", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    //envío de inversiones
    /*    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.IsspolSicav'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new GetObjectCode()).GetCode("IsspolSicav", "View", suffix: false);
        comm.ExecuteNonQuery();*/

    //
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.CancelarTpoAnterior'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("CancelarTpoAnterior", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.InsertarTituloPortafolio'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new InsertarTituloPortafolio()).GetCode();
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ActualizarTituloPortafolio'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new ActualizarTituloPortafolio()).GetCode();
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.SpProvisionInversiones'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("SpProvisionInversiones", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.SpProvisionInversionesView'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("SpProvisionInversionesView", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();


    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.OtrasCuentasPorCobrarView'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("OtrasCuentasPorCobrarView", "View", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.IsspolRentaFijaView'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("IsspolRentaFijaView", "View", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerTodosSaldoYDetallePortafolio'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerTodosSaldoYDetallePortafolio", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.spPerfilesIsspolMantenimiento'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("spPerfilesIsspolMantenimiento", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    //
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.IsspolCrearConfiguracion'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("IsspolCrearConfiguracion", "siisspolweb", suffix: false, plural: false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.IsspolComprobanteRecuperacion'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("IsspolComprobanteRecuperacion", "siisspolweb", suffix: false, plural: false);
    comm.ExecuteNonQuery();
 /*   
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerConfAsientoRecuperacion'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerConfAsientoRecuperacion", "siisspolweb", suffix: false, plural: false);
    comm.ExecuteNonQuery();
    */
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.GenerarRecuperacionInversion'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("GenerarRecuperacionInversion", "siisspolweb", suffix: false, plural:false);
    comm.ExecuteNonQuery();
    
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.IsspolInsertarComprobanteRecuperacion'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("IsspolInsertarComprobanteRecuperacion", "siisspolweb", suffix: false, plural: false);
    comm.ExecuteNonQuery();
   
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerEnvioRecuperacionISSPOL'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerEnvioRecuperacionISSPOL", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();
    

    #region Llamadas a GenerarCompraVentaFlujo
    if (false)
    {

        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ActualizarTituloPortafolio'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new ActualizarTituloPortafolio()).GetCode();
        comm.ExecuteNonQuery();

        comm.CommandText = "if not exists(select * from information_schema.columns where column_name='CRE_REPORTANTE_TIV_ID' and table_name='CONTRATO_REPORTO')" +
            "alter table BVQ_BACKOFFICE.CONTRATO_REPORTO ADD CRE_REPORTANTE_TIV_ID INT";
        comm.ExecuteNonQuery();

        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ActualizarTitulosPortafolioLiquidacion'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new ActualizarTitulosPortafolioLiquidacion()).GetCode();
        comm.ExecuteNonQuery();

        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.CancelarTituloPortafolio'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new CancelarTituloPortafolio()).GetCode();
        comm.ExecuteNonQuery();

        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.CancelarMovimientoTituloPortafolio'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new CancelarMovimientoTituloPortafolio()).GetCode();
        comm.ExecuteNonQuery();

        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.InsertarLiquidezPortafolio'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new InsertarLiquidezPortafolio()).GetCode();
        comm.ExecuteNonQuery();

        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ReversarLiquidacion'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new ReversarLiquidacion()).GetCode();
        comm.ExecuteNonQuery();

        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ReliquidarReporto'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new ReliquidarReporto()).GetCode();
        comm.ExecuteNonQuery();

        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.InsertarRetrasos'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new InsertarRetrasos()).GetCode();
        comm.ExecuteNonQuery();

        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ActualizarEstadoCuentaPortafolioVenta'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new ActualizarEstadoCuentaPortafolioVenta()).GetCode();
        comm.ExecuteNonQuery();
    }
    #endregion

    conn.Close();
    scope.Complete();
}

static void ChangeScript(SqlCommand comm, string fullName)
{
    comm.CommandText = (new GetObjectCode()).GetCode(fullName, "Change Script", suffix: false);
}