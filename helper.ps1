$AZURE_SUB="7386cd39-b109-4cc6-bb80-bf12413d0a99"
$RG_LA="nyp-logicapp-std-demo-rg"
$LA_NAME="ghsample-test-deploy"
$LOCATION="eastus2"

# 1. Zip the logic dir
cd .\logic
mkdir -p -Force ../output
Compress-Archive -Path . -DestinationPath ../output/logic.zip -Force
cd ../

# 2. Get publish profile
$profile = Get-AzWebAppPublishingProfile `
-ResourceGroupName $RG_LA `
-Name $LA_NAME

$profile = $profile.Replace("`r", "").Replace("`n", "")

# 3. Deploy to Azure Logic App
# - name: Deploy to Azure Logic App
#   uses: Azure/functions-action@v1.3.1
#   id: la
#   with:
#     app-name: ${{secrets.RG_LA}}
#     package: './output/logic.zip'
#     publish-profile: ${{steps.publishprofile.outputs.profile}}
az functionapp deploy --resource-group $RG_LA --name $LA_NAME --src-path ./output/logic.zip --type zip

# 4. Swap parameter files and deploy
az functionapp deploy --resource-group $RG_LA --name $LA_NAME --src-path  logic/azure.parameters.json --type static --target-path parameters.json
