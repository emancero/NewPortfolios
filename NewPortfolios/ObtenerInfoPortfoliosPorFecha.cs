using System.IO;

class ObtenerInfoPortfoliosPorFecha
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Stored Procedures\"
            + @"BVQ_BACKOFFICE.ObtenerInfoPortfoliosPorFecha."
            + @"StoredProcedure.sql");
    }
}
