using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker.Http;
using AzureFunctionsOpenAIExtension.Models;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker.Extensions.OpenAI.TextCompletion;
using Microsoft.Azure.Functions.Worker.Extensions.OpenAI.Assistants;

namespace AzureFunctionsOpenAIExtension;

public class Chat
{
    private static ILogger<Chat> _logger;

    public Chat(ILogger<Chat> logger)
    {
        _logger = logger;
    }

    [Function(nameof(CreateChatBot))]
    public static async Task<ChatOutput> CreateChatBot(
        [HttpTrigger(AuthorizationLevel.Function, "put", Route = "chats/{chatId}")] HttpRequestData req,
        string chatId)
    {
        var responseJson = new { chatId };

        using StreamReader reader = new(req.Body);

        string request = await reader.ReadToEndAsync();

        Request? createRequestBody = JsonSerializer.Deserialize<Request>(request) 
            ?? throw new ArgumentException("Invalid request body. Make sure that you pass in {\"instructions\": value } as the request body.");
        
        return new ChatOutput
        {
            HttpResponse = new ObjectResult(responseJson) { StatusCode = 201 },
            ChatRequest = new AssistantCreateRequest(chatId, createRequestBody.Instructions)
        };
    }

    [Function(nameof(PostToChatBot))]
    public static async Task<IActionResult> PostToChatBot(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = "chats/{chatId}")] HttpRequestData req,
        string chatId,
        [AssistantPostInput("{chatId}", "{Query.message}", Model = "%CHAT_MODEL_DEPLOYMENT_NAME%")] AssistantState state)
    {
        _logger.LogInformation($"Posting to chat bot for chatId: {chatId}");
        return new OkObjectResult(state.RecentMessages.LastOrDefault()?.Content ?? "No response returned.");
    }

    [Function(nameof(GetChatState))]
    public static async Task<IActionResult> GetChatState(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "chats/{chatId}")] HttpRequestData req,
        string chatId,
        [AssistantQueryInput("{chatId}", TimestampUtc = "{Query.timestampUTC}")] AssistantState state)
    {
        return new OkObjectResult(state);
    }

    [Function(nameof(Completions))]
    public static IActionResult Completions(
        [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req,
        [TextCompletionInput("{Prompt}", Model = "%CHAT_MODEL_DEPLOYMENT_NAME%")] TextCompletionResponse response,
        ILogger log)
    {
        string text = response.Content;
        return new OkObjectResult(text);
    }
}