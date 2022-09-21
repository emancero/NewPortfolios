using System.IO;

class ReliquidarReporto
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Stored Procedures\"
            + @"BVQ_BACKOFFICE.ReliquidarReporto."
            + @"StoredProcedure.sql");
    }
}
