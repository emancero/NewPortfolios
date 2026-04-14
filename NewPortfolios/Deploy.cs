using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NewPortfolios
{
    internal class Deploy
    {
        internal void CreateObject(string schema, string objectName, string type, SqlCommand comm)
        {
                comm.CommandText = "dropifexists '"+schema+"."+objectName+"'";
                comm.ExecuteNonQuery();
                comm.CommandText = (new GetObjectCode()).GetCode(objectName, type, suffix: false);
                comm.ExecuteNonQuery();
        }

        internal Deploy(string name, SqlConnection conn)
        {
            if (conn == null) return;

            SqlCommand comm = conn.CreateCommand();

            comm.CommandText = (new GetObjectCode()).GetCode("Menu Reportes de Inversiones", "Change Script", suffix: false);
            comm.ExecuteNonQuery();

            CreateObject("BVQ_BACKOFFICE", "spUltimoDiaLaborable", "Stored Procedure", comm);
            CreateObject("dbo", "fnUltimoDiaLaborable", "Function", comm);
        }
    }
}
