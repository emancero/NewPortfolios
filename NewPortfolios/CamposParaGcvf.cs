using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

class CamposParaGcvf
{
    public string FilesRoot { get; set; }
    public CamposParaGcvf(string filesRoot)
    {
        FilesRoot = filesRoot;
    }
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Change Scripts\"
            + @"Campos para GenerarCompraVentaFlujo."
            + @"sql");
    }
}
