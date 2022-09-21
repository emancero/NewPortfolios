//Ejecuta scripts en el orden correcto
using Microsoft.Data.SqlClient;
using System.Transactions;

string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["SIPLAConnectionString"].ToString();
SqlConnection conn = new SqlConnection(connStr);
SqlCommand comm = conn.CreateCommand();
comm.CommandType = System.Data.CommandType.Text;
conn.Open();
using (TransactionScope scope = new TransactionScope())
{
    comm.CommandType = System.Data.CommandType.Text;


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

    scope.Complete();
}
conn.Close();
