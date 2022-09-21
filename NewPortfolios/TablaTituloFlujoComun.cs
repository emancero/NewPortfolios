using System.IO;

class TablaTituloFlujoComun
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Change Scripts\"
            + @"Tabla titulo_flujo_comun."
            + @"sql");
    }
}
