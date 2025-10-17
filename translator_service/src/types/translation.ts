/**
 * Translation system interfaces
 */

export interface TranslationEntry {
  textId: string;
  sourceText: string;
  sourceLang: string;
  targetLang: string;
  translatedText: string;
  timestamp: Date;
  provider: string;
}

export interface TranslationRequest {
  textId: string;
  text: string;
  sourceLang: string;
  targetLang: string;
}

export interface TranslationResponse {
  textId: string;
  translatedText: string;
  provider: string;
  confidence?: number;
}

export interface TranslationProvider {
  name: string;
  translate(requests: TranslationRequest[]): Promise<TranslationResponse[]>;
  getSupportedLanguages(): Promise<string[]>;
}

export interface TranslationConfig {
  defaultProvider: string;
  providers: Record<string, any>;
  cacheConfig: {
    ttl: number;
    maxEntries: number;
  };
  batchConfig: {
    maxBatchSize: number;
    batchTimeout: number;
  };
}