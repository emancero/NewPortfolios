using System.IO;

class CamposParaGcvf
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Change Scripts\"
            + @"Campos para GenerarCompraVentaFlujo."
            + @"sql");
    }
}
