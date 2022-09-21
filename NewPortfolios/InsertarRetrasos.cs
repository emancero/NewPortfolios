using System.IO;

class InsertarRetrasos
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Stored Procedures\"
            + @"BVQ_BACKOFFICE.InsertarRetrasos."
            + @"StoredProcedure.sql");
    }
}
