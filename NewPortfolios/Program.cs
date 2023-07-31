//Ejecuta scripts en el orden correcto
using Microsoft.Data.SqlClient;
using System.Transactions;

string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SIPLAConnectionString"].ToString();
using (TransactionScope scope = new TransactionScope())
{
    SqlConnection conn = new SqlConnection(connStr);
    SqlCommand comm = conn.CreateCommand();
    comm.CommandType = System.Data.CommandType.Text;
    conn.Open();

    comm.CommandType = System.Data.CommandType.Text;

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
        comm.CommandText = (new GetObjectCode()).GetCode("GenerarTituloFlujoComun", "StoredProcedure",false);
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

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.HtpCupon'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("BVQ_BACKOFFICE.HtpCupon", "View");
    comm.ExecuteNonQuery();

    comm.CommandText = (new CamposParaGcvf()).GetCode();
    comm.ExecuteNonQuery();

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

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.EventoPortafolioCorte'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new EventoPortafolioCorte()).GetCode();
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ISSPOL_PROGS'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new ISSPOL_PROGS()).GetCode();
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.PortafolioCorte'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("BVQ_BACKOFFICE.PortafolioCorte","View");
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerInfoPortfoliosPorFecha'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new ObtenerInfoPortfoliosPorFecha()).GetCode();
    comm.ExecuteNonQuery();

    comm.CommandText = (new GetObjectCode()).GetCode("Campo TIV_ID en LIQUIDEZ_CACHE y evtTemp", "Change Script",suffix:false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.PrepararLiquidezCache'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("PrepararLiquidezCache", "Stored Procedure", suffix:false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerDetallePortafolioConLiquidezView'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerDetallePortafolioConLiquidezView", "View", suffix:false);
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.ObtenerDetallePortafolioConLiquidez'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GetObjectCode()).GetCode("ObtenerDetallePortafolioConLiquidez", "Stored Procedure", suffix: false);
    comm.ExecuteNonQuery();

    #region Llamadas a GenerarCompraVentaFlujo
    if (false)
    {
        comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.InsertarTituloPortafolio'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new InsertarTituloPortafolio()).GetCode();
        comm.ExecuteNonQuery();

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
