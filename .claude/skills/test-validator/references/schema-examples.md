# JSON Schema Examples

## Basic Schema
```json
{
  "type": "object",
  "properties": {
    "name": {"type": "string"},
    "age": {"type": "number"}
  },
  "required": ["name"]
}
```

## Array Schema
```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "id": {"type": "integer"}
    }
  }
}
```

## Nested Schema
```json
{
  "type": "object",
  "properties": {
    "user": {
      "type": "object",
      "properties": {
        "profile": {
          "type": "object",
          "properties": {
            "email": {"type": "string", "format": "email"}
          }
        }
      }
    }
  }
}