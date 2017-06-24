New-ListView -Width 600 -Height 600 -DataBinding @{
    ItemsSource = New-Binding -Path Output -IsAsync -UpdateSourceTrigger PropertyChanged 
} -View {
    New-GridView -AllowsColumnReorder -Columns {
        New-GridViewColumn "Id"
        New-GridViewColumn "Name" 
        New-GridViewColumn "WS"
        New-GridViewColumn "cpu"
        New-GridViewColumn "path"
         
    }
} -DataContext {
    Get-PowerShellDataSource -Script { Get-Process  }
} -On_Loaded {
    Register-PowerShellCommand -Run -In "0:0:15" -ScriptBlock {
        $window.Content.DataContext.Script = $window.Content.DataContext.Script
    }
} -asjob