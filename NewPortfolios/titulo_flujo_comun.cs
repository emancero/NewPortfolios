using System.IO;

class titulo_flujo_comun
{
    public string FilesRoot { get; set; }
    public titulo_flujo_comun(string filesRoot)
    {
        FilesRoot = filesRoot;
    }
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Views\"
            + @"BVQ_ADMINISTRACION.titulo_flujo_comun."
            + @"View.sql");
    }
}

