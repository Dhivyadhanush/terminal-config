# Gemini Chat for Palette

`/askgemini <question>` opens a new Gemini chat in Ghostty with that question.

- `/askgemini` with no question shows **New Gemini chat**, **Resume latest chat**,
  and every saved session.
- Type a question and pick **Continue latest chat with this question** to add it
  to the most recent session instead of starting a new one.
- Aliases: `/gemini`, `/gem`, `/gchat`.

Sessions live in `~/.gemini/tmp/palette-gemini/chats/` (Gemini CLI's normal
storage). The provider reads those files directly so listing stays fast.

The model is in `model.txt` (default `gemini-3.8-flash`). The API key is read by
Gemini CLI from the macOS Keychain (`gemini-cli-api-key`); no key is stored here.
