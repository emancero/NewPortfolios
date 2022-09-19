using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

class CompraVentaFlujo
{
    public string FilesRoot { get; set; }
    public CompraVentaFlujo(string filesRoot)
    {
        FilesRoot = filesRoot;
    }
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Views\"
            + @"BVQ_BACKOFFICE.CompraVentaFlujo."
            + @"View.sql");
    }
}
