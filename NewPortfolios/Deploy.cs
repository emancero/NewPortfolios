using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.AccessControl;
using System.Text;
using System.Threading.Tasks;

namespace NewPortfolios
{
    internal class Deploy
    {
        internal void ExecuteScript(string objectName, string type, SqlCommand comm)
        {
                comm.CommandText = (new GetObjectCode()).GetCode(objectName, type, suffix: false);
                comm.ExecuteNonQuery();
        }
        internal void CreateObject(string schema, string objectName, string type, SqlCommand comm)
        {
            comm.CommandText = "dropifexists '" + schema + "." + objectName + "'";
            comm.ExecuteNonQuery();
            ExecuteScript(objectName, type, comm);
        }

        internal Deploy(string name, SqlConnection conn)
        {
            if (conn == null) return;

            SqlCommand comm = conn.CreateCommand();

            ExecuteScript("Menu Reportes de Inversiones", "Change Script", comm);
            comm.ExecuteNonQuery();

            CreateObject("BVQ_BACKOFFICE", "spUltimoDiaLaborable", "Stored Procedure", comm);
            CreateObject("dbo", "fnUltimoDiaLaborable", "Function", comm);
            comm.CommandText = (new GetObjectCode()).GetCode("ACTIVOS_INMOBILIARIOS", "Change Script", suffix: false);
            comm.ExecuteNonQuery();
            CreateObject("BVQ_BACKOFFICE", "ObtenerActivosInmobiliariosISSPOL", "Stored Procedure", comm);
            CreateObject("BVQ_BACKOFFICE", "ActualizarActivosInmobiliariosISSPOL", "Stored Procedure", comm);
            CreateObject("BVQ_BACKOFFICE", "InsertarActivosInmobiliariosISSPOL", "Stored Procedure", comm);
            CreateObject("BVQ_BACKOFFICE", "ObtenerComposicionAccionariaISSPOL", "Stored Procedure", comm);

            ExecuteScript("SECTOR_ISSPOL", "Change Script", comm);
            CreateObject("BVQ_BACKOFFICE", "DetalleRecuperacionesIsspolFondos", "View", comm);
            CreateObject("BVQ_BACKOFFICE", "ObtenerIngresosPorInversiones", "Stored Procedure", comm);

            CreateObject("BVQ_ADMINISTRACION", "PeriodicidadSB", "View", comm);
            CreateObject("BVQ_BACKOFFICE", "DetallePortafolioBursatil", "View", comm);
            CreateObject("BVQ_BACKOFFICE", "ObtenerInversionesSC", "Stored Procedure", comm);

            CreateObject("BVQ_BACKOFFICE", "DetalleRecuperacionesIsspol", "View", comm);
            CreateObject("BVQ_BACKOFFICE", "ObtenerRecuperacionesSBS", "Stored Procedure", comm);

            ExecuteScript("Migrar tabla dividendos", "Change Script", comm);
            CreateObject("BVQ_BACKOFFICE", "ObtenerComposicionAccionariaISSPOL", "Stored Procedure", comm);


        }
    }
}
