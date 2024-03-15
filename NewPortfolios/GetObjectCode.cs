using System.IO;

class GetObjectCode
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode(string fullName, string type, bool suffix=true, bool plural=true)
    {
        string folderName = (type == "StoredProcedure") ? "Stored Procedure" : type;
        return File.ReadAllText(FilesRoot
            + folderName+(plural?"s":"")
            + @"\"
            + fullName
            + (suffix?@"."+type:"")+@".sql");
    }
}
