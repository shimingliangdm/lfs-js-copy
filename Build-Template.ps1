param(
	[parameter(Mandatory=$false)]$CodePath="./index.js",
	[parameter(Mandatory=$false)]$IncompleteTemplatePath="./template-code-incomplete.json",
	[parameter(Mandatory=$false)]$OutputPath="./lfs-oss-template.json")
function Get-CodeZipBase64{
param([parameter(Mandatory=$false)]$Path)
Add-Type -AssemblyName System.IO.Compression 
$ZipCreateMode = [System.IO.Compression.ZipArchiveMode]::Create;
$byte_stream = New-Object System.IO.MemoryStream
$zip = New-Object System.IO.Compression.ZipArchive -ArgumentList $byte_stream,$ZipCreateMode,true
$zip_stream = $zip.CreateEntry("index.js").Open()
$plain_file_bytes = [byte[]](Get-Content -Encoding Byte -Raw $Path)
[System.IO.MemoryStream]::new($plain_file_bytes).CopyTo($zip_stream)
$zip_stream.Close()
$zip.Dispose()
return [Convert]::ToBase64String($byte_stream.ToArray())
}
$Template = Get-Content $IncompleteTemplatePath -Encoding utf8 | ConvertFrom-Json
$Template.Resources."LFS后端函数".Properties.Code.ZipFile = (Get-CodeZipBase64 $CodePath)
$Template| ConvertTo-Json -Depth 33 -Compress | %{[Text.Encoding]::UTF8.GetBytes($_)}|Set-Content $OutputPath -Encoding Byte