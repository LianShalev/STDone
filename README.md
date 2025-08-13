STDone

Video → Test Doc

Generate Software Test Documents (STD) automatically from testing videos. Upload a recording of a manual test session (optionally with rrweb/console/HAR), and STDone extracts steps, expected/actual behavior, severity, and produces a clean, exportable test document.

Features

Video → STD: upload a session video and get a structured test document (Markdown/PDF/DOCX).

AI extraction: speech-to-text (Whisper), keyframes + OCR, optional rrweb/HAR merge → steps & evidence.

Dynamic templates: choose which columns your Test Cases table has (Title/Steps/Expected/Actual/Severity/Tags… or custom).

Accounts & quotas:

Guest: up to 3 reports/day, no history (session-only).

Free user: 3 reports/day, history of last 10.

Premium: unlimited reports & history, folders to organize docs.

Admin: block users, view analytics (visits, signups, subscriptions, generated docs per month/year).

Privacy-ready: consent & suppression lists for marketing messages.

How it works (MVP pipeline)

Upload a video (MP4/MOV). Optional: rrweb JSON + HAR + console logs.

Process: FFmpeg → audio, Whisper ASR → transcript; keyframe clustering + OCR → on-screen text; merge with rrweb/HAR.

AI creates Scenarios and Test Cases; suggests Severity; fills dynamic template fields (with confidence + fallback when unsure).

Render to Markdown → export PDF/DOCX; store doc + evidence links.

Tech stack

Backend: FastAPI (Python), Celery/RQ (background jobs)

AI/ML: Whisper (ASR), OpenCV + OCR, LLM for drafting cases (via prompt templates)

DB: MySQL 8 (ERD in /docs/erd.dbml), object storage (local/S3)

Frontend: React + Vite (upload UI, history, folders)

ERD & DBML live in /docs. The schema covers accounts/usage, analysis sessions, dynamic templates, docs, analytics, and marketing consent.
