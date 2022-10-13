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
    if (false)
    {
        comm.CommandText = "dropifexists 'BVQ_ADMINISTRACION.TITULO_FLUJO_COMUN'";
        comm.ExecuteNonQuery();

        comm.CommandText = "dropifexists 'BVQ_ADMINISTRACION.TITULO_FLUJO_COMUN_RAW'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new TablaTituloFlujoComunRaw()).GetCode();
        comm.ExecuteNonQuery();

        comm.CommandText = (new titulo_flujo_comun()).GetCode();
        comm.ExecuteNonQuery();

        comm.CommandText = "dropifexists 'BVQ_ADMINISTRACION.GenerarTituloFlujoComun'";
        comm.ExecuteNonQuery();
        comm.CommandText = (new GenerarTituloFlujoComun()).GetCode();
        comm.ExecuteNonQuery();
    }
    #endregion

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

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.EventoPortafolioCorte'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new EventoPortafolioCorte()).GetCode();
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
