# AzureFunctionsOpenAIExtension

This project demonstrates the integration of Azure Functions with the OpenAI extension. It includes infrastructure setup using Bicep templates and a .NET Azure Functions application.

## Prerequisites

- [.NET 8 SDK](https://dotnet.microsoft.com/download)
- [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
- [Azurite](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azurite?tabs=visual-studio-code%2Cblob-storage) (for local Azure Storage emulation)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)

## Setup

1. **Create a new HTTP trigger function (if needed):**

    ```sh
    func new --template "HTTP trigger" --name ChatFunction
    ```
1. **Configure local settings:**

    Add the following settings to `local.settings.json`:

    ```json
    {
      "IsEncrypted": false,
      "Values": {
        "AzureWebJobsStorage": "UseDevelopmentStorage=true",
        "FUNCTIONS_WORKER_RUNTIME": "dotnet",
        "AZURE_OPENAI_ENDPOINT": "<your-openai-endpoint>",
        "AZURE_OPEN_KEY": "<your-openai-key>",
        "CHAT_MODEL_DEPLOYMENT_NAME": "<your-chat-model-deployment-name>"
      }
    }
    ```

1. **Install Azurite for local development:**

    Follow the instructions [here](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azurite?tabs=visual-studio-code%2Cblob-storage) to install and run Azurite.

## Infrastructure Deployment

The infrastructure is defined using Bicep templates located in the `infra` directory.

1. **Deploy the infrastructure using `azd`:**

    ```sh
    azd up
    ```

    Follow the prompts to configure your deployment. This command will provision all necessary resources in Azure.

2. **Clean up resources using `azd`:**

    ```sh
    azd down
    ```

    This command will remove all resources that were provisioned by `azd up`.

## Project Structure

- `src/`: Contains the source code for the Azure Functions application.
  - `Chat.cs`: The main function implementation.
  - `Program.cs`: The entry point for the function app.
  - `Models/`: Contains data models used in the application.
- `infra/`: Contains Bicep templates for infrastructure deployment.
  - `main.bicep`: Main Bicep template for resource deployment.
  - `core/`: Contains submodules for specific resources.
- `.azure/`: Environment variables used by `azd`.
- `azure.yaml`: Configuration file with mapping between the application and infra resources.

## Running the Project

1. **Start the Azure Functions host:**

    ```sh
    func start
    ```

2. **Trigger the function:**

    You can use tools like [Postman](https://www.postman.com/) or [curl](https://curl.se/) to send HTTP requests to the function endpoint.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.