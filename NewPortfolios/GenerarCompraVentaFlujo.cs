using System.IO;

class GenerarCompraVentaFlujo
{
    public string FilesRoot { get; set; }
    public GenerarCompraVentaFlujo(string filesRoot)
    {
        FilesRoot = filesRoot;
    }
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Stored Procedures\"
            + @"BVQ_BACKOFFICE.GenerarCompraVentaFlujo."
            + @"StoredProcedure.sql");
    }
}
