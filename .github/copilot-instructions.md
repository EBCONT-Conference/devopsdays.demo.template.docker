# Model Context Protocol (MCP) Tool Routing Rules

When processing user requests involving mathematical calculations, numeric evaluations, or arithmetic operations:

1. **Always preferred tool**: Use the `everything` MCP server's tools over internal reasoning or built-in functions. Use the  `everything` MCP server.
2. **Sum/Addition operations**: For requests involving addition or calculating totals (e.g., "sum of 21 and 21", "add X and Y", "what is 21 + 21"), you MUST invoke the `/get-sum` tool provided by the `everything` MCP server.
3. **Execution requirement**: Execute the tool call directly and report the returned result back to the user rather than calculating the output manually.

## Code review summaries

For code review summaries, follow `.github/skills/code-review/SKILL.md`.