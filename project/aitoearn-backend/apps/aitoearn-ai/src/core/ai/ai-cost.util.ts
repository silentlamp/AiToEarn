/**
 * AI Model Cost Calculator
 *
 * Per-model pricing (USD per 1M tokens).
 * Update this table when provider pricing changes.
 */

interface ModelPricing {
  inputPer1M: number
  outputPer1M: number
}

const MODEL_PRICING: Record<string, ModelPricing> = {
  // OpenAI
  'gpt-4o': { inputPer1M: 2.5, outputPer1M: 10 },
  'gpt-4o-mini': { inputPer1M: 0.15, outputPer1M: 0.6 },
  'gpt-4-turbo': { inputPer1M: 10, outputPer1M: 30 },
  'gpt-4': { inputPer1M: 30, outputPer1M: 60 },
  'gpt-3.5-turbo': { inputPer1M: 0.5, outputPer1M: 1.5 },
  'o1': { inputPer1M: 15, outputPer1M: 60 },
  'o1-mini': { inputPer1M: 3, outputPer1M: 12 },
  'o3-mini': { inputPer1M: 1.1, outputPer1M: 4.4 },

  // Anthropic
  'claude-sonnet-4-20250514': { inputPer1M: 3, outputPer1M: 15 },
  'claude-3-5-sonnet-20241022': { inputPer1M: 3, outputPer1M: 15 },
  'claude-3-5-sonnet-20240620': { inputPer1M: 3, outputPer1M: 15 },
  'claude-3-opus-20240229': { inputPer1M: 15, outputPer1M: 75 },
  'claude-3-sonnet-20240229': { inputPer1M: 3, outputPer1M: 15 },
  'claude-3-haiku-20240307': { inputPer1M: 0.25, outputPer1M: 1.25 },

  // Gemini
  'gemini-2.0-flash': { inputPer1M: 0.1, outputPer1M: 0.4 },
  'gemini-2.0-flash-lite': { inputPer1M: 0.075, outputPer1M: 0.3 },
  'gemini-1.5-pro': { inputPer1M: 1.25, outputPer1M: 5 },
  'gemini-1.5-flash': { inputPer1M: 0.075, outputPer1M: 0.3 },
}

const DEFAULT_PRICING: ModelPricing = { inputPer1M: 0, outputPer1M: 0 }

export interface CostResult {
  cost: number
  inputCost: number
  outputCost: number
}

export function calculateAiCost(
  model: string,
  inputTokens?: number,
  outputTokens?: number,
): CostResult {
  const normalizedModel = model.toLowerCase().replace(/^.*\//, '')
  const pricing = Object.entries(MODEL_PRICING).find(
    ([key]) => normalizedModel.includes(key.toLowerCase()),
  )?.[1] ?? DEFAULT_PRICING

  const inputCost = ((inputTokens ?? 0) / 1_000_000) * pricing.inputPer1M
  const outputCost = ((outputTokens ?? 0) / 1_000_000) * pricing.outputPer1M

  return {
    cost: Math.round((inputCost + outputCost) * 1_000_000) / 1_000_000,
    inputCost: Math.round(inputCost * 1_000_000) / 1_000_000,
    outputCost: Math.round(outputCost * 1_000_000) / 1_000_000,
  }
}
