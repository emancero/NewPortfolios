using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

class GenerarTituloFlujoComun
{
    public string FilesRoot { get; set; }
    public GenerarTituloFlujoComun(string filesRoot)
    {
        FilesRoot = filesRoot;
    }
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Stored Procedures\"
            + @"BVQ_ADMINISTRACION.GenerarTituloFlujoComun."
            + @"StoredProcedure.sql");
    }
}
