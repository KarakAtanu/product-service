var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();
builder.Services.AddHealthChecks();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.MapHealthChecks("/health");

app.MapGet("api/v1/products", () =>
{
    var products = new[]
    {
        new  { Id = 1, Name = "Product 1", Price = 10.0m },
        new  { Id = 2, Name = "Product 2", Price = 20.0m },
        new  { Id = 3, Name = "Product 3", Price = 30.0m }
    };

    return Results.Ok(products);
});

app.Run();