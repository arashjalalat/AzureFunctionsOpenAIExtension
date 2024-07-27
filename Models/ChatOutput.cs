using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Extensions.OpenAI.Assistants;

namespace AzureFunctionsOpenAIExtension.Models
{
    public class ChatOutput
    {
        [AssistantCreateOutput()]
        public AssistantCreateRequest? ChatRequest { get; set; }

        [HttpResult]
        public IActionResult? HttpResponse { get; set; }
    }
}