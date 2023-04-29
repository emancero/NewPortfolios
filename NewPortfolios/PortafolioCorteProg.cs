using System.IO;

class PortafolioCorteProg
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode()
    {
        return File.ReadAllText(FilesRoot
            + @"Views\"
            + @"BVQ_BACKOFFICE.PortafolioCorteProg."
            + @"View.sql");
    }
}
