using System.IO;

class CancelarMovimientoTituloPortafolio
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Stored Procedures\"
            + @"BVQ_BACKOFFICE.CancelarMovimientoTituloPortafolio."
            + @"StoredProcedure.sql");
    }
}
