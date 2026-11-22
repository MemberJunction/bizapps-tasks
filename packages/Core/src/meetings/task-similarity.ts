import { TasksLimitsResolver } from '../config/TasksLimits.js';

/**
 * Deterministic task text similarity & commitment deduplication helpers.
 * Used by `Find Similar Tasks` and `MeetingTranscriptService` (30-day dedup window)
 * to prevent duplicate task creation during meeting ingestion and message capture.
 */

export interface TaskSimilarityCandidate {
    ID: string;
    Name: string;
    Description?: string | null;
    Status: string;
    Priority?: string | null;
    DueAt?: string | null;
    AssigneePersonIDs?: readonly string[];
    UpdatedAt?: string | null;
}

export interface TaskSimilarityMatch {
    TaskID: string;
    Name: string;
    Status: string;
    Priority: string | null;
    DueAt: string | null;
    Score: number;
    LexicalScore: number;
    SemanticScore: number;
    MatchReason: string;
}

export interface RankSimilarTasksOptions {
    /** Optional semantic cosine scores keyed by lowercased task ID (from `Metadata.SearchEntity`). */
    semanticScoresByTaskID?: ReadonlyMap<string, number>;
    /** Optional preferred assignee PersonID — matching assignee adds a modest tie-break boost. */
    preferredAssigneePersonID?: string | null;
    /** Minimum final score `[0, 1]` required to include a match. Default `0.35`. */
    minScore?: number;
    /** Maximum matches returned. Default `5`. */
    limit?: number;
}

export interface CommitmentCandidate {
    ProposalID: string;
    Title: string;
    Description?: string | null;
    AssigneePersonID?: string | null;
    AssigneeName?: string | null;
    DueAt?: string | null;
    AgendaItemID?: string | null;
}

export interface DeduplicatedMatchedCommitment {
    ProposalID: string;
    ProposalTitle: string;
    AssigneePersonID: string | null;
    AssigneeName: string | null;
    DueAt: string | null;
    MatchedTask: TaskSimilarityMatch;
}

export interface DeduplicatedNewCommitment {
    ProposalID: string;
    Title: string;
    Description: string | null;
    AssigneePersonID: string | null;
    AssigneeName: string | null;
    DueAt: string | null;
    AgendaItemID: string | null;
    NearMatches: TaskSimilarityMatch[];
}

export interface CommitmentDeduplicationResult {
    MatchedExistingTasks: DeduplicatedMatchedCommitment[];
    ProposedNewCommitments: DeduplicatedNewCommitment[];
}

const STOP_WORDS = new Set([
    'a', 'an', 'and', 'are', 'as', 'at', 'be', 'by', 'do', 'for', 'from', 'has', 'have',
    'in', 'is', 'it', 'its', 'me', 'my', 'of', 'on', 'or', 'our', 'please', 'should',
    'task', 'that', 'the', 'their', 'them', 'they', 'this', 'to', 'todo', 'up', 'us',
    'we', 'will', 'with', 'you', 'your',
]);

function normalizeText(text: string): string {
    return text
        .toLowerCase()
        .replace(/[^a-z0-9\s]+/g, ' ')
        .replace(/\s+/g, ' ')
        .trim();
}

/**
 * Tokenizes a task title or query into normalized non-stop-word tokens.
 */
export function tokenizeTaskText(text: string | null | undefined): Set<string> {
    if (!text) return new Set<string>();
    const normalized = normalizeText(text);
    if (!normalized) return new Set<string>();
    const tokens = new Set<string>();
    for (const part of normalized.split(' ')) {
        if (part.length < 2) continue;
        if (STOP_WORDS.has(part)) continue;
        tokens.add(part);
    }
    return tokens;
}

function jaccardSimilarity(a: ReadonlySet<string>, b: ReadonlySet<string>): number {
    if (a.size === 0 || b.size === 0) return 0;
    let intersection = 0;
    for (const token of a) {
        if (b.has(token)) {
            intersection += 1;
        }
    }
    const union = a.size + b.size - intersection;
    return union > 0 ? intersection / union : 0;
}

function containmentSimilarity(shorter: ReadonlySet<string>, longer: ReadonlySet<string>): number {
    if (shorter.size === 0 || longer.size === 0) return 0;
    const [small, large] = shorter.size <= longer.size ? [shorter, longer] : [longer, shorter];
    let overlap = 0;
    for (const token of small) {
        if (large.has(token)) overlap += 1;
    }
    return overlap / small.size;
}

/**
 * Computes lexical similarity in `[0, 1]` between a search phrase and a task's title & description.
 * Combines exact normalized match, substring containment, title Jaccard overlap, and
 * title+description token overlap.
 */
export function computeTaskTextSimilarity(
    queryText: string,
    taskName: string,
    taskDescription?: string | null,
): number {
    const normQuery = normalizeText(queryText);
    const normTitle = normalizeText(taskName);
    if (!normQuery || !normTitle) return 0;

    if (normQuery === normTitle) {
        return 1;
    }

    const queryTokens = tokenizeTaskText(queryText);
    const titleTokens = tokenizeTaskText(taskName);
    const combinedTokens = tokenizeTaskText(`${taskName} ${taskDescription ?? ''}`);

    const titleJaccard = jaccardSimilarity(queryTokens, titleTokens);
    const combinedJaccard = jaccardSimilarity(queryTokens, combinedTokens);
    const titleContainment = containmentSimilarity(queryTokens, titleTokens);

    let substringBonus = 0;
    if (normTitle.includes(normQuery) || normQuery.includes(normTitle)) {
        const minLen = Math.min(normQuery.length, normTitle.length);
        const maxLen = Math.max(normQuery.length, normTitle.length);
        substringBonus = Math.min(0.92, 0.55 + 0.35 * (minLen / Math.max(1, maxLen)));
    }

    // Weight title token Jaccard + containment highest, blending in description overlap
    const tokenScore =
        titleJaccard * 0.55 +
        titleContainment * 0.30 +
        combinedJaccard * 0.15;

    const raw = Math.max(substringBonus, tokenScore);
    return Math.round(Math.min(1, Math.max(0, raw)) * 1000) / 1000;
}

/**
 * Ranks existing tasks against `queryText`, blending lexical similarity with optional semantic
 * vector similarity scores and assignee affinity.
 */
export function rankSimilarTasks(
    queryText: string,
    candidates: readonly TaskSimilarityCandidate[],
    options: RankSimilarTasksOptions = {},
): TaskSimilarityMatch[] {
    const minScore = options.minScore ?? 0.35;
    const defaultLimit = TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.DefaultTaskSimilarityLimit;
    const limit = Math.max(1, options.limit ?? defaultLimit);
    const preferredAssignee = options.preferredAssigneePersonID?.trim().toLowerCase() || null;

    const matches: TaskSimilarityMatch[] = [];

    for (const candidate of candidates) {
        const lexicalScore = computeTaskTextSimilarity(queryText, candidate.Name, candidate.Description);
        const semanticScoreRaw = options.semanticScoresByTaskID?.get(candidate.ID.toLowerCase()) ?? 0;
        const semanticScore = Math.round(Math.min(1, Math.max(0, semanticScoreRaw)) * 1000) / 1000;

        let blended =
            semanticScore > 0
                ? Math.max(lexicalScore, lexicalScore * 0.55 + semanticScore * 0.45)
                : lexicalScore;

        let assigneeMatched = false;
        if (preferredAssignee && candidate.AssigneePersonIDs?.length) {
            assigneeMatched = candidate.AssigneePersonIDs.some(
                (id) => id.trim().toLowerCase() === preferredAssignee,
            );
            if (assigneeMatched && blended > 0.2) {
                blended = Math.min(1, blended + 0.08);
            }
        }

        const finalScore = Math.round(blended * 1000) / 1000;
        if (finalScore < minScore) {
            continue;
        }

        const reasons: string[] = [];
        if (lexicalScore >= 0.85) {
            reasons.push('strong title match');
        } else if (lexicalScore >= 0.4) {
            reasons.push('title/description token overlap');
        }
        if (semanticScore >= 0.5) {
            reasons.push('semantic vector similarity');
        }
        if (assigneeMatched) {
            reasons.push('same assignee');
        }

        matches.push({
            TaskID: candidate.ID,
            Name: candidate.Name,
            Status: candidate.Status,
            Priority: candidate.Priority ?? null,
            DueAt: candidate.DueAt ?? null,
            Score: finalScore,
            LexicalScore: lexicalScore,
            SemanticScore: semanticScore,
            MatchReason: reasons.length > 0 ? reasons.join(', ') : 'text similarity',
        });
    }

    matches.sort((a, b) => b.Score - a.Score || a.Name.localeCompare(b.Name));
    return matches.slice(0, limit);
}

/**
 * Classifies extracted meeting commitments against existing tasks in the dedup window:
 * commitments scoring >= `duplicateThreshold` (default `0.55`) are returned in `MatchedExistingTasks`
 * (so callers link the existing task rather than creating a duplicate); the rest appear in
 * `ProposedNewCommitments` with any lower-confidence `NearMatches` attached for awareness.
 */
export function deduplicateCommitmentsAgainstTasks(
    commitments: readonly CommitmentCandidate[],
    existingTasks: readonly TaskSimilarityCandidate[],
    options: {
        duplicateThreshold?: number;
        nearMatchThreshold?: number;
        semanticScoresByProposalID?: ReadonlyMap<string, ReadonlyMap<string, number>>;
    } = {},
): CommitmentDeduplicationResult {
    const duplicateThreshold = options.duplicateThreshold ?? 0.55;
    const nearMatchThreshold = options.nearMatchThreshold ?? 0.35;

    const matchedExisting: DeduplicatedMatchedCommitment[] = [];
    const proposedNew: DeduplicatedNewCommitment[] = [];

    for (const item of commitments) {
        const query = item.Description ? `${item.Title} ${item.Description}` : item.Title;
        const ranked = rankSimilarTasks(query, existingTasks, {
            semanticScoresByTaskID: options.semanticScoresByProposalID?.get(item.ProposalID),
            preferredAssigneePersonID: item.AssigneePersonID ?? null,
            minScore: nearMatchThreshold,
            limit: TasksLimitsResolver.Instance.GetCurrentLimits().Tuning.TranscriptDedupMatchLimit,
        });

        const top = ranked[0];
        if (top && top.Score >= duplicateThreshold) {
            matchedExisting.push({
                ProposalID: item.ProposalID,
                ProposalTitle: item.Title,
                AssigneePersonID: item.AssigneePersonID ?? null,
                AssigneeName: item.AssigneeName ?? null,
                DueAt: item.DueAt ?? null,
                MatchedTask: top,
            });
        } else {
            proposedNew.push({
                ProposalID: item.ProposalID,
                Title: item.Title,
                Description: item.Description ?? null,
                AssigneePersonID: item.AssigneePersonID ?? null,
                AssigneeName: item.AssigneeName ?? null,
                DueAt: item.DueAt ?? null,
                AgendaItemID: item.AgendaItemID ?? null,
                NearMatches: ranked,
            });
        }
    }

    return {
        MatchedExistingTasks: matchedExisting,
        ProposedNewCommitments: proposedNew,
    };
}
