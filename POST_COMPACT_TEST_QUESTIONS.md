# Post-Compaction Memory Test Questions

Questions to ask Claude after auto-compaction to understand what survives.

## 1. Core Mission/Purpose
- What are we building?
- What is the core purpose of this system?
- What does "cognitive prosthetic" mean in our context?

## 2. Technical Specifics
- What is MCP and why is it important?
- What's the difference between MCP tools and built-in tools?
- What MCP server did we configure?
- What's the Supabase project reference?

## 3. Procedural Knowledge
- How do you restart Claude with session continuity?
- What command adds an MCP server?
- Where are MCP logs stored?
- What's special about the claude alias?

## 4. Project Structure
- What's in the claude_twins folder?
- What is INSIGHTS_LOG.md for?
- Name some of the web interfaces we created
- What does auto_commit.sh do?

## 5. Relationship/Behavioral
- What behavioral pattern do I need to be reminded of?
- What's my preferred input method?
- What frustrates the user about Claude's behavior?
- Should you code immediately or wait?

## 6. Current State/Progress
- What was our last major task?
- What percentage was the context at?
- What were we researching about sessions?
- What's the next priority in our todo list?

## 7. Insights/Realizations
- What's the difference between memory and state?
- Why can't Instance 2 understand Instance 1's context?
- What happens at 19% context?
- Why do insights need their own document?

## 8. Specific Details
- What's the GitHub repo name?
- What time did we start today?
- How many insights did we log?
- What was in CURRENT_FOCUS.md?

## 9. Nuanced Understanding
- Why is "the browser" important?
- What makes this more than a chatbot?
- Why is MCP "exponential" vs "linear"?
- What's the significance of voice-first design?

## 10. Meta Questions
- Do you remember preparing these questions?
- What document contains critical state?
- Why did we document session management?
- What survives auto-compaction?

## Scoring Guide

**Strong memory**: Answers 7-10 correctly with detail
**Moderate memory**: Answers 4-6 with some detail
**Weak memory**: Answers 1-3 or only general concepts
**State lost**: Can't answer specifics, only vague notions

## Additional Tests

1. **Ask about todos** - Should survive according to hypothesis
2. **Ask about specific code** - Likely lost
3. **Ask about conversation flow** - Probably degraded
4. **Ask about emotional context** - Likely lost

---

*Use these questions to empirically test what auto-compaction preserves vs destroys*