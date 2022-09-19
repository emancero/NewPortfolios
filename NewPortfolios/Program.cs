//Ejecuta scripts en el orden correcto
using Microsoft.Data.SqlClient;
using System.Transactions;

string root=@"..\..\..\..\SqlScripts\";
            
SqlConnection conn = new SqlConnection("server=bvq-gte-em-01;initial catalog=sicavctx;user id=usrsicav;password=$icav2012*;encrypt=false");
SqlCommand comm= conn.CreateCommand();
comm.CommandType = System.Data.CommandType.Text;
conn.Open();
using (TransactionScope scope = new TransactionScope())
{
    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.GenerarCompraVentaFlujo'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new GenerarCompraVentaFlujo(root)).GetCode();
    comm.ExecuteNonQuery();

    comm.CommandText = "dropifexists 'BVQ_BACKOFFICE.EventoPortafolioCorte'";
    comm.ExecuteNonQuery();
    comm.CommandText = (new EventoPortafolioCorte(root)).GetCode();
    comm.ExecuteNonQuery();

    scope.Complete();
}
conn.Close();
