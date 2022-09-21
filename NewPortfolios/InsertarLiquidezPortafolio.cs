﻿using System.IO;

class InsertarLiquidezPortafolio
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Stored Procedures\"
            + @"BVQ_BACKOFFICE.InsertarLiquidezPortafolio."
            + @"StoredProcedure.sql");
    }
}
