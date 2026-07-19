---
type: command
title: "/media:extract-pdf"
description: "Gemini-only command that extracts structured data from PDFs — invoices, tables, forms — as JSON, CSV, markdown or text."
tags: [commands, operations, providers]
timestamp: 2026-07-19
status: active
domain: operations
resource: ".gemini/commands/media/extract-pdf.toml"
sources:
  - ".gemini/commands/media/extract-pdf.toml"
verified_against: "fd0fc6a"
---

# /media:extract-pdf

The document member of the media family. Point it at an invoice, a report or a whole folder of
PDFs and it returns structured data rather than a description.

## Overview

Gemini-only. Detects the document type, then extracts along a type-specific shape: invoices and
receipts become JSON, tables become CSV, forms become a flat field map. Declared capabilities are
text extraction with formatting preservation, table detection, form field extraction, invoice
parsing and multi-page processing. All of it is model inference — there is no `pdftotext`, no OCR
library and no parsing dependency in the file.

## Invocation

- `/media:extract-pdf <path>` — a single PDF.
- `/media:extract-pdf <directory>` — batch mode; processes all PDFs and generates combined output.
  The combining rule for a folder of heterogeneous document types is not specified.
- `--json`, `--csv`, `--markdown`, `--text` — output format.
- Precondition: PDFs up to 100MB, stated as Gemini 3.

## What It Does

- Detects the target with `ls -la {{args}} || echo "File not found"` — note this command uses
  `ls -la` where the audio and video media commands use `file`.
- Identifies document type (invoice, form, report, contract) and detects tables, forms and
  structured content, extracting text with section awareness.
- Maps invoices to a JSON shape with vendor, invoice number, date, an items array of description,
  quantity and price, plus subtotal, tax and total.
- Emits in the requested format.

## Provider Parity

- Gemini — the only implementation. No `.claude/commands` counterpart, so zero Claude parity.
- DOC DRIFT: alone among the eleven media commands this file carries no privacy note, yet document
  contents necessarily reach the Gemini API by the same mechanism.
- Open questions: whether output is written to disk or only returned in-conversation is UNKNOWN —
  no output path is defined. Source caveats: complex layouts may need multiple passes, handwritten
  OCR quality varies, and scanned documents need good image quality.

## Citations

- [Gemini CLI Authoring Guide](../../guides/GEMINI_CLI_AUTHORING_GUIDE.md) — names this command in
  its media command layout.
