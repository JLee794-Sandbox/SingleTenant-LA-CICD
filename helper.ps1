$AZURE_SUB="7386cd39-b109-4cc6-bb80-bf12413d0a99"
$RG_LA="nyp-logicapp-std-demo-rg"
$LA_NAME="nyp-logicapp-std-demo"
# $LA_NAME="ghsample-test-deploy"
# $LOCATION="eastus2"
$FolderName = "./output"

# Dependencies
# az extension add --yes --source https://aka.ms/logicapp-latest-py2.py3-none-any.whl
if (-not (Test-Path $FolderName)) {
  New-Item $FolderName -ItemType Directory
  Write-Host "Folder Created successfully"
}


# 1. Zip the logic dir
Write-Debug "Compressing Logic App Deployment into $FolderName directory..."
Compress-Archive -Path ".\logic\*" -DestinationPath ./output/logic.zip -Force


# 2. Get publish profile (this step is not required if you're az logined)
# Write-Debug "Retrieving publish profile..."
# $profile = Get-AzWebAppPublishingProfile `
# -ResourceGroupName $RG_LA `
# -Name $LA_NAME

# $profile = $profile.Replace("`r", "").Replace("`n", "")

# 3. Deploy to Azure Logic App
# az functionapp deploy --resource-group $RG_LA --name $LA_NAME --src-path ./output/logic.zip --type zip (this works too)
Write-Debug "Deploying to Azure Logic App..."
az logicapp deployment source config-zip --name $LA_NAME --resource-group $RG_LA --subscription $AZURE_SUB --src ./output/logic.zip

Write-Debug "Swapping parameters..."
# 4. Swap parameter files and deploy
az functionapp deploy --resource-group $RG_LA --name $LA_NAME --src-path  logic/azure.parameters.json --type static --target-path parameters.json
