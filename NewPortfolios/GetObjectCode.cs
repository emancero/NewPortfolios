using System.IO;

class GetObjectCode
{
    public string FilesRoot { get; set; } = @"..\..\..\..\SqlScripts\";
    public string GetCode(string fullName, string type, bool suffix=true, bool plural=true)
    {
        string folderName = (type == "StoredProcedure") ? "Stored Procedure" : type;
        return File.ReadAllText(GetFilePath(fullName, type, suffix, plural, folderName));
    }

    public void WriteCode(string fullName, string type, string text, bool suffix = true, bool plural = true)
    {
        string folderName = (type == "StoredProcedure") ? "Stored Procedure" : type;
        File.WriteAllText(GetFilePath(fullName, type, suffix, plural, folderName), text);
    }

    public string GetFilePath(string fullName, string type, bool suffix, bool plural, string folderName)
    {
        return FilesRoot
                    + folderName + (plural ? "s" : "")
                    + @"\"
                    + fullName
                    + (suffix ? @"." + type : "") + @".sql";
    }

    public string ChangeAlterToCreate(string commandText)
    {
        return commandText.Substring(0, 5) == "alter" ? "create" + commandText.Substring(5) : commandText;
    }
}
