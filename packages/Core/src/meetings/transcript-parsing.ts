/**
 * Pure, browser- and server-safe transcript parsing and normalization utilities
 * for WebVTT (Zoom, Teams, Google Meet), SRT, JSON segments, and plain-text transcripts.
 */

export type TranscriptFormat = 'vtt' | 'srt' | 'text' | 'json';

export interface ParsedTranscriptTurn {
    Speaker: string | null;
    Text: string;
}

export interface ParsedTranscript {
    PlainText: string;
    Speakers: string[];
    Turns: ParsedTranscriptTurn[];
    Format: Exclude<TranscriptFormat, 'json'>;
}

interface JsonTranscriptSegment {
    speaker?: string | null;
    speaker_name?: string | null;
    name?: string | null;
    text?: string | null;
    content?: string | null;
}

interface JsonTranscriptPayload {
    transcript?: string | null;
    text?: string | null;
    segments?: JsonTranscriptSegment[] | null;
    utterances?: JsonTranscriptSegment[] | null;
}

const VTT_TIMESTAMP_LINE =
    /^\s*(?:\d{2}:)?\d{2}:\d{2}\.\d{3}\s*-->\s*(?:\d{2}:)?\d{2}:\d{2}\.\d{3}(?:\s+.*)?$/;
const SRT_TIMESTAMP_LINE =
    /^\s*\d{2}:\d{2}:\d{2},\d{3}\s*-->\s*\d{2}:\d{2}:\d{2},\d{3}(?:\s+.*)?$/;
const VTT_VOICE_TAG = /^<v(?:\.[^>\s]+)?\s+([^>]+)>([\s\S]*)$/i;
const SPEAKER_PREFIX = /^([A-Za-z][A-Za-z0-9 .,'()-]{0,60}):\s+(.+)$/;
const DECISION_LINE = /^(?:[-*•]\s*)?(?:DECISION|DECIDED|AGREED|RESOLUTION)\s*:\s*(.+)$/i;

function stripInlineTags(text: string): string {
    return text
        .replace(/<\/?(?:v|c|i|b|u|lang|ruby|rt)\b[^>]*>/gi, '')
        .replace(/\s+/g, ' ')
        .trim();
}

function addUniqueSpeaker(speakers: string[], seen: Set<string>, speaker: string | null): void {
    if (!speaker) return;
    const normalized = speaker.trim();
    if (!normalized) return;
    const key = normalized.toLowerCase();
    if (!seen.has(key)) {
        seen.add(key);
        speakers.push(normalized);
    }
}

function appendMergedTurn(turns: ParsedTranscriptTurn[], speaker: string | null, rawText: string): void {
    const text = rawText.trim();
    if (!text) return;
    const prev = turns[turns.length - 1];
    if (prev && prev.Speaker && speaker && prev.Speaker.toLowerCase() === speaker.toLowerCase()) {
        prev.Text = `${prev.Text} ${text}`.replace(/\s+/g, ' ').trim();
        return;
    }
    turns.push({ Speaker: speaker ? speaker.trim() : null, Text: text });
}

function formatTurnsToPlainText(turns: readonly ParsedTranscriptTurn[]): string {
    return turns
        .map((turn) => (turn.Speaker ? `${turn.Speaker}: ${turn.Text}` : turn.Text))
        .join('\n');
}

function extractSpeakerAndText(line: string): { speaker: string | null; text: string } {
    const trimmed = line.trim();
    const voiceMatch = VTT_VOICE_TAG.exec(trimmed);
    if (voiceMatch) {
        const speaker = voiceMatch[1].trim();
        const text = stripInlineTags(voiceMatch[2]);
        return { speaker: speaker || null, text };
    }

    const cleaned = stripInlineTags(trimmed);
    const prefixMatch = SPEAKER_PREFIX.exec(cleaned);
    if (prefixMatch) {
        const candidateSpeaker = prefixMatch[1].trim();
        // Avoid treating directives like ACTION:, TODO:, DECISION:, NOTE: as speaker names.
        if (!/^(?:ACTION(?:\s+ITEM)?|TODO|FOLLOW[- ]UP|DECISION|DECIDED|AGREED|NOTE|SUMMARY|TOPIC)$/i.test(candidateSpeaker)) {
            return { speaker: candidateSpeaker, text: prefixMatch[2].trim() };
        }
    }

    return { speaker: null, text: cleaned };
}

/**
 * Parses a WebVTT transcript (e.g. from Zoom Cloud Recordings, Microsoft Teams, or Google Meet)
 * into clean speaker-labeled plain text, merging consecutive cues from the same speaker.
 */
export function parseWebVttTranscript(vtt: string): ParsedTranscript {
    const lines = vtt.replace(/^\uFEFF/, '').split(/\r?\n/);
    const turns: ParsedTranscriptTurn[] = [];
    const speakers: string[] = [];
    const seenSpeakers = new Set<string>();

    let skippingBlock = false;
    let pendingCueLines: string[] = [];

    const flushCue = (): void => {
        if (pendingCueLines.length === 0) return;
        const combined = pendingCueLines.join(' ').trim();
        pendingCueLines = [];
        if (!combined) return;
        const { speaker, text } = extractSpeakerAndText(combined);
        if (!text) return;
        addUniqueSpeaker(speakers, seenSpeakers, speaker);
        appendMergedTurn(turns, speaker, text);
    };

    for (let i = 0; i < lines.length; i++) {
        const rawLine = lines[i];
        const trimmed = rawLine.trim();

        if (!trimmed) {
            flushCue();
            skippingBlock = false;
            continue;
        }

        if (/^WEBVTT(?:\s|$)/i.test(trimmed)) {
            continue;
        }

        if (/^(?:NOTE|STYLE|REGION)(?:\s|$)/i.test(trimmed)) {
            flushCue();
            skippingBlock = true;
            continue;
        }

        if (skippingBlock) {
            continue;
        }

        if (VTT_TIMESTAMP_LINE.test(trimmed)) {
            flushCue();
            continue;
        }

        // Skip standalone cue identifiers immediately preceding a timestamp line
        const nextTrimmed = lines[i + 1]?.trim() ?? '';
        if (VTT_TIMESTAMP_LINE.test(nextTrimmed)) {
            continue;
        }

        pendingCueLines.push(trimmed);
    }

    flushCue();

    return {
        PlainText: formatTurnsToPlainText(turns),
        Speakers: speakers,
        Turns: turns,
        Format: 'vtt',
    };
}

/**
 * Parses a SubRip (`.srt`) transcript into speaker-labeled plain text.
 */
export function parseSrtTranscript(srt: string): ParsedTranscript {
    const lines = srt.replace(/^\uFEFF/, '').split(/\r?\n/);
    const turns: ParsedTranscriptTurn[] = [];
    const speakers: string[] = [];
    const seenSpeakers = new Set<string>();

    let pendingCueLines: string[] = [];

    const flushCue = (): void => {
        if (pendingCueLines.length === 0) return;
        const combined = pendingCueLines.join(' ').trim();
        pendingCueLines = [];
        if (!combined) return;
        const { speaker, text } = extractSpeakerAndText(combined);
        if (!text) return;
        addUniqueSpeaker(speakers, seenSpeakers, speaker);
        appendMergedTurn(turns, speaker, text);
    };

    for (let i = 0; i < lines.length; i++) {
        const trimmed = lines[i].trim();
        if (!trimmed) {
            flushCue();
            continue;
        }
        if (SRT_TIMESTAMP_LINE.test(trimmed)) {
            flushCue();
            continue;
        }
        const nextTrimmed = lines[i + 1]?.trim() ?? '';
        if (/^\d+$/.test(trimmed) && SRT_TIMESTAMP_LINE.test(nextTrimmed)) {
            continue;
        }
        pendingCueLines.push(trimmed);
    }

    flushCue();

    return {
        PlainText: formatTurnsToPlainText(turns),
        Speakers: speakers,
        Turns: turns,
        Format: 'srt',
    };
}

function parsePlainTextTranscript(raw: string): ParsedTranscript {
    const lines = raw.replace(/^\uFEFF/, '').split(/\r?\n/);
    const turns: ParsedTranscriptTurn[] = [];
    const speakers: string[] = [];
    const seenSpeakers = new Set<string>();

    for (const line of lines) {
        const trimmed = line.trim();
        if (!trimmed) continue;
        const { speaker, text } = extractSpeakerAndText(trimmed);
        if (!text) continue;
        addUniqueSpeaker(speakers, seenSpeakers, speaker);
        turns.push({ Speaker: speaker, Text: text });
    }

    return {
        PlainText: formatTurnsToPlainText(turns),
        Speakers: speakers,
        Turns: turns,
        Format: 'text',
    };
}

function tryParseJsonTranscript(raw: string): ParsedTranscript | null {
    const trimmed = raw.trim();
    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
        return null;
    }
    try {
        const parsed = JSON.parse(trimmed) as JsonTranscriptPayload | JsonTranscriptSegment[];
        const segments = Array.isArray(parsed)
            ? parsed
            : Array.isArray(parsed.segments)
              ? parsed.segments
              : Array.isArray(parsed.utterances)
                ? parsed.utterances
                : null;
        if (segments) {
            const turns: ParsedTranscriptTurn[] = [];
            const speakers: string[] = [];
            const seenSpeakers = new Set<string>();
            for (const seg of segments) {
                const text = (seg.text ?? seg.content ?? '').trim();
                if (!text) continue;
                const speaker = (seg.speaker ?? seg.speaker_name ?? seg.name ?? '').trim() || null;
                addUniqueSpeaker(speakers, seenSpeakers, speaker);
                appendMergedTurn(turns, speaker, text);
            }
            return {
                PlainText: formatTurnsToPlainText(turns),
                Speakers: speakers,
                Turns: turns,
                Format: 'text',
            };
        }
        if (!Array.isArray(parsed)) {
            const inner = (parsed.transcript ?? parsed.text ?? '').trim();
            if (inner) {
                return normalizeTranscriptText(inner);
            }
        }
        return null;
    } catch {
        return null;
    }
}

/**
 * Auto-detects WebVTT, SRT, JSON segment arrays, or plain text and normalizes into speaker-labeled lines.
 */
export function normalizeTranscriptText(
    raw: string,
    formatHint?: TranscriptFormat,
): ParsedTranscript {
    const cleaned = raw.replace(/^\uFEFF/, '').trim();
    if (!cleaned) {
        return { PlainText: '', Speakers: [], Turns: [], Format: 'text' };
    }

    if (formatHint === 'vtt') {
        return parseWebVttTranscript(cleaned);
    }
    if (formatHint === 'srt') {
        return parseSrtTranscript(cleaned);
    }
    if (formatHint === 'json') {
        const fromJson = tryParseJsonTranscript(cleaned);
        if (fromJson) return fromJson;
    }

    if (/^WEBVTT(?:\s|$)/i.test(cleaned) || VTT_TIMESTAMP_LINE.test(cleaned.split(/\r?\n/).find((l) => l.includes('-->')) ?? '')) {
        return parseWebVttTranscript(cleaned);
    }

    if (SRT_TIMESTAMP_LINE.test(cleaned.split(/\r?\n/).find((l) => l.includes('-->')) ?? '')) {
        return parseSrtTranscript(cleaned);
    }

    if (cleaned.startsWith('{') || cleaned.startsWith('[')) {
        const fromJson = tryParseJsonTranscript(cleaned);
        if (fromJson) return fromJson;
    }

    return parsePlainTextTranscript(cleaned);
}

/**
 * Extracts explicit decisions recorded in a transcript or meeting summary (`DECISION:`, `DECIDED:`, `AGREED:`).
 */
export function extractDecisionsFromText(text: string): string[] {
    const decisions: string[] = [];
    const seen = new Set<string>();
    for (const rawLine of text.split(/\r?\n/)) {
        const trimmed = rawLine.trim();
        if (!trimmed) continue;
        // Strip leading "Speaker: " prefix if present so spoken "Alice: DECISION: ..." is also captured.
        const speakerStripped = SPEAKER_PREFIX.test(trimmed)
            ? trimmed.replace(SPEAKER_PREFIX, '$2').trim()
            : trimmed;
        const match = DECISION_LINE.exec(speakerStripped) ?? DECISION_LINE.exec(trimmed);
        if (!match) continue;
        const decision = match[1].trim();
        const key = decision.toLowerCase();
        if (decision && !seen.has(key)) {
            seen.add(key);
            decisions.push(decision);
        }
    }
    return decisions;
}
