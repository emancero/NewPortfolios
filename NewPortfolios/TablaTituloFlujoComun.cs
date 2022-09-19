using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

class TablaTituloFlujoComun
{
    public string FilesRoot { get; set; }
    public TablaTituloFlujoComun(string filesRoot)
    {
        FilesRoot = filesRoot;
    }
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Change Scripts\"
            + @"Tabla titulo_flujo_comun."
            + @"sql");
    }
}
