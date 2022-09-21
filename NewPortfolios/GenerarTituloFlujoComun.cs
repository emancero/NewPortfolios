using System.IO;

class GenerarTituloFlujoComun
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Stored Procedures\"
            + @"BVQ_ADMINISTRACION.GenerarTituloFlujoComun."
            + @"StoredProcedure.sql");
    }
}
