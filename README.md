# AzureFunctionsOpenAIExtension
Project to demo Azure Functions with OpenAI extension.

1. func init
2. func new -> http trigger
3. dotnet add package Microsoft.Azure.Functions.Worker.Extensions.OpenAI  --prerelease
4. add the following:

 `AZURE_OPENAI_ENDPOINT` and `AZURE_OPENAI_KEY` to `local.settings.json`
 `CHAT_MODEL_DEPLOYMENT_NAME`
4. install azurite (https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azurite?tabs=visual-studio-code%2Cblob-storage)
