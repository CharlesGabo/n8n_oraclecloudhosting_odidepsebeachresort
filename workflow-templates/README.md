# Workflow Templates

## Mock Resort AI Support Agent — Gemini

Import `mock-resort-ai-support-agent.json` into n8n 2.22.6. It contains no API
key, Meta token, or other credential. After import:

1. Open **Google Gemini Chat Model**.
2. Create or select a Google PaLM/Gemini API credential and save it.
3. Keep `models/gemini-3.6-flash`, or choose an available Flash model listed by
   your credential. Older accounts may expose different models; use the model list
   returned for the connected credential rather than typing an unavailable name.
4. Confirm **Resort Support Agent** connects to **Safety and Handoff Gate**. This
   deterministic node overrides live-availability claims and incomplete replies.
5. Select **Chat** at the bottom of the workflow editor and test the questions in
   `../mock-data/test-cases.json`.
6. Keep the workflow inactive. It is a local prototype, not the Meta webhook.

The FAQ is embedded in the AI Agent system message so the prototype remains
portable. When real resort data exists, replace the entire mock knowledge section
and review every policy before activation.
