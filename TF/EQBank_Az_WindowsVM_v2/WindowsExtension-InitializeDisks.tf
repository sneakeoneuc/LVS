module "InitializeDisks" {
  source             = "./modules/WindowsScriptExtension_v1"
  scriptName         = "InitializeDisks.ps1" #The name of the script to be run. Path and name must be seperate."
  scriptPath         = "scripts"             #"The path of the script to be run.  Path and name must be seperate."
  virtual_machine_id = azurerm_windows_virtual_machine.main.id

  depends_on = [
    module.AddDisks
  ]

}


