using System.IO;

class EventoPortafolioCorte
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";

    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Views\"
            + @"BVQ_BACKOFFICE.EventoPortafolioCorte."
            + @"View.sql");
    }
}

