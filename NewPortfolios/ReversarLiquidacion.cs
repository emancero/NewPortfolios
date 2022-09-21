using System.IO;

class ReversarLiquidacion
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Stored Procedures\"
            + @"BVQ_BACKOFFICE.ReversarLiquidacion."
            + @"StoredProcedure.sql");
    }
}
