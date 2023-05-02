using System.IO;

class GetObjectCode
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode(string fullName, string type)
    {
        return File.ReadAllText(FilesRoot
            + type+@"s\"
            + fullName+@"."
            + type+@".sql");
    }
}
