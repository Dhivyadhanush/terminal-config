#!/usr/bin/env python3
"""Palette provider: /askgemini — Gemini CLI chats with resumable sessions.

Opens Gemini in Ghostty using a fixed workspace so every chat belongs to one
project and can be listed/resumed. The API key is read by Gemini CLI from the
macOS Keychain (service: gemini-cli-api-key).

Sessions are read straight from the CLI's .jsonl files instead of
`gemini --list-sessions`, which tries to summarise every session and can take
several seconds (or stall while the model is busy).
"""

import hashlib
import json
import shlex
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

HOME = Path.home()
CHAT_DIR = HOME / ".local/share/palette-gemini"
SESSIONS_DIR = HOME / ".gemini/tmp/palette-gemini/chats"
GHOSTTY = "/Applications/Ghostty.app/Contents/MacOS/ghostty"
GEMINI = "/opt/homebrew/bin/gemini"
HERE = Path(__file__).resolve().parent
MODEL_FILE = HERE / "model.txt"
MODEL = MODEL_FILE.read_text().strip() if MODEL_FILE.exists() else "gemini-3.8-flash"

_session_cache: tuple[float, list[dict]] = (0.0, [])
CACHE_SECONDS = 5.0


def send(obj: dict) -> None:
    sys.stdout.write(json.dumps(obj, separators=(",", ":")) + "\n")
    sys.stdout.flush()


def gemini_argv(*extra: str) -> list[str]:
    return [GEMINI, "-m", MODEL, "--skip-trust", *extra]


def ghostty_run(argv: list[str]) -> list[str]:
    """Ghostty -e via a login shell, with the fixed chat directory as cwd."""
    script = "cd " + shlex.quote(str(CHAT_DIR)) + " && exec " + " ".join(
        shlex.quote(part) for part in argv
    )
    return [GHOSTTY, "-e", "/bin/sh", "-lc", script]


def parse_time(value) -> datetime | None:
    if not isinstance(value, str) or not value:
        return None
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None


def relative_time(moment: datetime | None) -> str:
    if moment is None:
        return ""
    now = datetime.now(timezone.utc)
    seconds = max(0, int((now - moment).total_seconds()))
    if seconds < 60:
        return "just now"
    minutes = seconds // 60
    if minutes < 60:
        return f"{minutes} min ago"
    hours = minutes // 60
    if hours < 24:
        return f"{hours} h ago"
    days = hours // 24
    if days == 1:
        return "yesterday"
    if days < 7:
        return f"{days} days ago"
    return moment.astimezone().strftime("%d %b %Y")


def message_text(content) -> str:
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for part in content:
            if isinstance(part, dict) and isinstance(part.get("text"), str):
                parts.append(part["text"])
        return "\n".join(parts)
    return ""


def read_session(path: Path, index: int) -> dict | None:
    session_id = path.stem.split("-")[-1]
    title = ""
    start: datetime | None = None
    updated: datetime | None = None
    try:
        with path.open(encoding="utf-8", errors="replace") as handle:
            for _ in range(200):
                line = handle.readline()
                if not line:
                    break
                line = line.strip()
                if not line:
                    continue
                try:
                    record = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if isinstance(record.get("sessionId"), str):
                    session_id = record["sessionId"]
                start = parse_time(record.get("startTime")) or start
                updated = parse_time(record.get("lastUpdated")) or updated
                if record.get("type") == "user" and not title:
                    candidate = " ".join(message_text(record.get("content")).split())
                    # Imported/agent sessions can start with a context block,
                    # which is not a useful row title.
                    if candidate and not candidate.startswith("<session_context>"):
                        title = candidate
    except OSError:
        return None
    if not title:
        title = "Untitled chat"
    return {
        "index": index,
        "id": session_id,
        "title": title[:90],
        "when": relative_time(updated or start or datetime.fromtimestamp(path.stat().st_mtime, timezone.utc)),
        "start": start or datetime.fromtimestamp(path.stat().st_mtime, timezone.utc),
    }


def fetch_sessions() -> list[dict]:
    global _session_cache
    now = time.time()
    cached_at, cached = _session_cache
    if cached and now - cached_at < CACHE_SECONDS:
        return cached
    paths = sorted(SESSIONS_DIR.glob("session-*.jsonl")) if SESSIONS_DIR.is_dir() else []
    sessions: list[dict] = []
    for position, path in enumerate(paths, start=1):
        session = read_session(path, position)
        if session:
            sessions.append(session)
    _session_cache = (now, sessions)
    return sessions


def session_item(session: dict, query: str | None = None) -> dict:
    resume = gemini_argv("--resume", str(session["index"]))
    subtitle = f"{session['when']} · resume chat"
    if query:
        resume = gemini_argv("--resume", str(session["index"]), "-i", query)
        subtitle = f"{session['when']} · continue with your question"
    return {
        "id": "session:" + session["id"],
        "title": session["title"],
        "subtitle": subtitle,
        "icon": {"type": "symbol", "value": "bubble.left.and.bubble.right"},
        "badge": "chat",
        "group": "Continue a session",
        "score": 800 - float(session["index"]),
        "actions": [
            {
                "id": "resume",
                "title": "Resume this chat",
                "kind": "run",
                "value": ghostty_run(resume),
            },
            {
                "id": "resume-new",
                "title": "Resume without the question",
                "kind": "run",
                "value": ghostty_run(gemini_argv("--resume", str(session["index"]))),
            },
        ],
    }


def new_chat_item() -> dict:
    return {
        "id": "new",
        "title": "New Gemini chat",
        "subtitle": f"Empty session · {MODEL}",
        "icon": {"type": "symbol", "value": "sparkles"},
        "badge": "new",
        "group": "New chat",
        "score": 20000,
        "actions": [
            {
                "id": "open",
                "title": "Open new chat",
                "kind": "run",
                "value": ghostty_run(gemini_argv()),
            }
        ],
    }


def ask_item(query: str) -> dict:
    digest = hashlib.sha1(query.encode("utf-8")).hexdigest()[:10]
    return {
        "id": "ask:" + digest,
        "title": "Ask Gemini: " + query[:90],
        "subtitle": f"New chat session · {MODEL}",
        "icon": {"type": "symbol", "value": "sparkles"},
        "badge": "ask",
        "group": "New chat",
        "score": 30000,
        "actions": [
            {
                "id": "ask",
                "title": "Ask in a new chat",
                "kind": "run",
                "value": ghostty_run(gemini_argv("-i", query)),
            },
            {
                "id": "empty",
                "title": "Open an empty chat instead",
                "kind": "run",
                "value": ghostty_run(gemini_argv()),
            },
        ],
    }


def continue_latest_item(query: str) -> dict:
    return {
        "id": "continue:latest",
        "title": "Continue latest chat with this question",
        "subtitle": f"{MODEL} · resumes the most recent session",
        "icon": {"type": "symbol", "value": "arrow.uturn.backward.circle"},
        "badge": "resume",
        "group": "Continue a session",
        "score": 25000,
        "actions": [
            {
                "id": "continue",
                "title": "Continue and ask",
                "kind": "run",
                "value": ghostty_run(gemini_argv("--resume", "latest", "-i", query)),
            },
            {
                "id": "resume",
                "title": "Just resume",
                "kind": "run",
                "value": ghostty_run(gemini_argv("--resume", "latest")),
            },
        ],
    }


def results(query: str) -> list[dict]:
    query = " ".join((query or "").split())
    sessions = fetch_sessions()
    newest_first = list(reversed(sessions))
    items: list[dict] = []

    if query:
        items.append(ask_item(query))
        if sessions:
            items.append(continue_latest_item(query))
        lowered = query.lower()
        items.extend(
            session_item(session, query=query)
            for session in newest_first
            if lowered in session["title"].lower()
        )
    else:
        items.append(new_chat_item())
        if sessions:
            latest = sessions[-1]
            items.append(
                {
                    "id": "resume:latest",
                    "title": "Resume latest chat",
                    "subtitle": f"{latest['when']} · {latest['title'][:70]}",
                    "icon": {"type": "symbol", "value": "clock.arrow.circlepath"},
                    "badge": "latest",
                    "group": "New chat",
                    "score": 19000,
                    "actions": [
                        {
                            "id": "resume",
                            "title": "Resume latest",
                            "kind": "run",
                            "value": ghostty_run(gemini_argv("--resume", "latest")),
                        }
                    ],
                }
            )
        items.extend(session_item(session) for session in newest_first[:15])
    return items


def main() -> None:
    CHAT_DIR.mkdir(parents=True, exist_ok=True)
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            message = json.loads(line)
        except json.JSONDecodeError:
            continue
        kind = message.get("type")
        if kind == "query":
            request_id = message.get("id", "")
            try:
                send(
                    {
                        "type": "results",
                        "id": request_id,
                        "items": results(message.get("text", "")),
                    }
                )
            except Exception as exc:  # never leave the host waiting
                send({"type": "error", "id": request_id, "message": str(exc)})
            send({"type": "done", "id": request_id})
        elif kind == "shutdown":
            break


if __name__ == "__main__":
    main()
