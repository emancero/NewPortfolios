using System.IO;

class ActualizarTituloPortafolio
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Stored Procedures\"
            + @"BVQ_BACKOFFICE.ActualizarTituloPortafolio."
            + @"StoredProcedure.sql");
    }
}
