using System.Text.Json.Serialization;

namespace AzureFunctionsOpenAIExtension.Models
{
    public class Request
    {
        [JsonPropertyName("instructions")]
        public string? Instructions { get; set; }
    }
}