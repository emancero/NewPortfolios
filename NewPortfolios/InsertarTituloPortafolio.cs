using System.IO;

class InsertarTituloPortafolio
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Stored Procedures\"
            + @"BVQ_BACKOFFICE.InsertarTituloPortafolio."
            + @"StoredProcedure.sql");
    }
}
