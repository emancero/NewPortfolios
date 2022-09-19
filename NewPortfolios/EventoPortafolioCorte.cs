using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

class EventoPortafolioCorte
{
    public string FilesRoot { get; set; }
    public EventoPortafolioCorte(string filesRoot)
    {
        FilesRoot = filesRoot;
    }
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Views\"
            + @"BVQ_BACKOFFICE.EventoPortafolioCorte."
            + @"View.sql");
    }
}

