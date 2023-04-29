using System.IO;

class ISSPOL_PROGS
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Views\"
            + @"BVQ_BACKOFFICE.ISSPOL_PROGS."
            + @"View.sql");
    }
}
