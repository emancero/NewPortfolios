using System.IO;

class ActualizarEstadoCuentaPortafolioVenta
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Stored Procedures\"
            + @"BVQ_BACKOFFICE.ActualizarEstadoCuentaPortafolioVenta."
            + @"StoredProcedure.sql");
    }
}
