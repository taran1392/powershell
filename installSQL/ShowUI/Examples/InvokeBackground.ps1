New-Grid -Columns 2 {            
    New-TextBlock -Margin 10 -TextWrapping Wrap -ZIndex 1 -HorizontalAlignment Left -FontWeight Bold -FontSize 12 -DataBinding @{            
        "Text" = "LastProgress.Activity"            
    }            
    New-TextBlock -Margin 10 -ZIndex 1 -TextWrapping Wrap -Column 1 -VerticalAlignment Bottom -HorizontalAlignment Right -FontStyle Italic -FontSize 12 -DataBinding @{            
        "Text" = "LastProgress.StatusDescription"            
    }            
    New-ProgressBar -ColumnSpan 2 -MinHeight 25 -Name ProgressPercent -DataBinding @{            
        "Value" = "LastProgress.PercentComplete"
    }            
}  -show
