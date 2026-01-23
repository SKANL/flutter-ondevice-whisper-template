/// Registry of AI models available for download.
///
/// Each model entry contains verified URLs from sherpa-onnx releases.
library;

/// Model types supported by the template.
enum AiModelType {
  // === ASR Models - Whisper ===
  whisperTinyEn,
  whisperTiny,
  whisperBaseEn,
  whisperBase,
  whisperSmallEn,
  whisperSmall,
  whisperMediumEn,
  whisperMedium,
  whisperLargeV3,
  whisperTurbo,
  whisperDistilLargeV3,
  whisperDistilSmallEn,
  // === ASR Models - Moonshine ===
  moonshineTinyInt8,
  moonshineBaseInt8,
  // === ASR Models - SenseVoice (Multilingual) ===
  senseVoiceMultilingual,
  senseVoiceMultilingualInt8,
  // === ASR Models - Streaming Zipformer ===
  streamingZipformerEnMobile,
  streamingZipformerEn20M,
  streamingZipformerBilingualZhEnMobile,
  streamingZipformerSmallBilingualZhEnMobile,
  streamingZipformerMultiZhHansInt8,
  streamingZipformerEsKroko,
  streamingZipformer8Lang,
  // === ASR Models - NeMo ===
  nemoConformerSmallEn,
  nemoFastConformerMultiInt8,
  nemoCanary180mInt8,
  nemoStreamingFastConformerInt8,
  // === ASR Models - Dolphin Multilingual ===
  dolphinBaseMultiInt8,
  dolphinSmallMultiInt8,
  // === ASR Models - Zipformer Offline ===
  zipformerSmallEn,
  zipformerEnPunctCase,
  zipformerGigaspeech,

  // === VAD Models ===
  sileroVad,

  // === Speaker Recognition Models ===
  speakerCampplusEn,
  speakerCampplusZh,
  speakerCampplusZhEnAdvanced,
  speakerEres2netv2Zh,
  speakerEres2netBase200kZh,
  speakerEres2netBase3dspeakerZh,
  speakerEres2netLarge3dspeakerZh,
  speakerEres2netEn,
  speakerEres2netZh,
  speakerNemoSpeakernet,
  speakerNemoTitanetLarge,
  speakerNemoTitanetSmall,
  wespeakerCampplusEn,
  wespeakerCampplusLmEn,
  wespeakerResnet152En,
  wespeakerResnet221En,
  wespeakerResnet293En,
  wespeakerResnet34En,
  wespeakerResnet34LmEn,
  wespeakerResnet34Zh,
  wespeakerResnet34LmZh,

  // === Audio Tagging Models ===
  audioTaggingCedBase,
  audioTaggingCedMini,
  audioTaggingCedSmall,
  audioTaggingCedTiny,
  audioTaggingZipformer,
  audioTaggingZipformerSmall,

  // === Keyword Spotting Models ===
  kwsGigaspeechMobile,
  kwsGigaspeech,
  kwsWenetspeechMobile,
  kwsWenetspeech,
  kwsZhEn,

  // === Speech Enhancement Models ===
  speechEnhancementGtcrn,

  // === Speaker Segmentation Models ===
  speakerSegmentationPyannote,

  // === Source Separation Models ===
  spleeter2stemsFp16,
  spleeter2stemsInt8,
  spleeter2stems,
  uvrMdxnetInst1,
  uvrMdxnetInst2,
  uvrMdxnetInst3,
  uvrMdxnetInstHq1,
  uvrMdxnetInstHq2,
  uvrMdxnetInstHq3,
  uvrMdxnetInstHq4,
  uvrMdxnetInstHq5,
  uvrMdxnetInstMain,
  uvrMdxnetVocFt,
  uvrMdxnetCrowdHq1,
  uvrMdxnet19703,
  uvrMdxnet29682,
  uvrMdxnet39662,
  uvrMdxnet9482,
  uvrMdxnetKara,
  uvrMdxnetKara2,
  uvrMdxnetMain,

  // === TTS Models - English ===
  ttsKittenMiniEn,
  ttsKittenNanoEn,
  ttsKokoroEn,
  ttsKokoroInt8En,
  ttsMatchaLjspeech,
  ttsMatchaZhEn,
  ttsVitsCoquiLjspeech,
  ttsVitsCoquiVctk,
  ttsVitsMeloEn,
  ttsVitsMmsEng,
  ttsVitsPiperLessacInt8,
  ttsVitsPiperRyanInt8,
  ttsVitsPiperAmyInt8,
  ttsVitsPiperLibrittsInt8,
  ttsVitsPiperJoeInt8,
  ttsVitsPiperGladosInt8,
  // === TTS Models - Spanish ===
  ttsVitsCoquiEsCss10,
  ttsVitsMmsSpa,
  ttsVitsPiperEsDanielaInt8,
  ttsVitsPiperEsCarlfmInt8,
  ttsVitsPiperEsDavefxInt8,
  ttsVitsPiperEsGladosInt8,
  ttsVitsPiperEsMiroInt8,
  ttsVitsPiperEsMxAldInt8,
  ttsVitsPiperEsMxClaudeInt8,
}

/// Configuration for an AI model.
class AiModelConfig {
  const AiModelConfig({
    required this.type,
    required this.name,
    required this.downloadUrl,
    required this.archiveName,
    required this.extractedDirName,
    required this.requiredFiles,
    required this.sizeEstimateMb,
    this.isArchive = true,
    this.category = 'General',
  });

  final AiModelType type;
  final String name;
  final String downloadUrl;
  final String archiveName;
  final String extractedDirName;
  final List<String> requiredFiles;
  final int sizeEstimateMb;
  final bool isArchive;
  final String category;
}

/// Registry of all available models with verified URLs.
class ModelRegistry {
  static const _baseUrl =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download';

  static const models = <AiModelType, AiModelConfig>{
    // ============================================================
    // ASR MODELS - WHISPER
    // ============================================================
    AiModelType.whisperTinyEn: AiModelConfig(
      type: AiModelType.whisperTinyEn,
      name: 'Whisper Tiny (English)',
      category: 'ASR',
      downloadUrl: '$_baseUrl/asr-models/sherpa-onnx-whisper-tiny.en.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-tiny.en.tar.bz2',
      extractedDirName: 'sherpa-onnx-whisper-tiny.en',
      requiredFiles: [
        'tiny.en-encoder.int8.onnx',
        'tiny.en-decoder.int8.onnx',
        'tiny.en-tokens.txt',
      ],
      sizeEstimateMb: 113,
    ),
    AiModelType.whisperTiny: AiModelConfig(
      type: AiModelType.whisperTiny,
      name: 'Whisper Tiny (Multilingual)',
      category: 'ASR',
      downloadUrl: '$_baseUrl/asr-models/sherpa-onnx-whisper-tiny.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-tiny.tar.bz2',
      extractedDirName: 'sherpa-onnx-whisper-tiny',
      requiredFiles: [
        'tiny-encoder.onnx',
        'tiny-decoder.onnx',
        'tiny-tokens.txt',
      ],
      sizeEstimateMb: 111,
    ),
    AiModelType.whisperBaseEn: AiModelConfig(
      type: AiModelType.whisperBaseEn,
      name: 'Whisper Base (English)',
      category: 'ASR',
      downloadUrl: '$_baseUrl/asr-models/sherpa-onnx-whisper-base.en.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-base.en.tar.bz2',
      extractedDirName: 'sherpa-onnx-whisper-base.en',
      requiredFiles: [
        'base.en-encoder.onnx',
        'base.en-decoder.onnx',
        'base.en-tokens.txt',
      ],
      sizeEstimateMb: 199,
    ),
    AiModelType.whisperBase: AiModelConfig(
      type: AiModelType.whisperBase,
      name: 'Whisper Base (Multilingual)',
      category: 'ASR',
      downloadUrl: '$_baseUrl/asr-models/sherpa-onnx-whisper-base.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-base.tar.bz2',
      extractedDirName: 'sherpa-onnx-whisper-base',
      requiredFiles: [
        'base-encoder.onnx',
        'base-decoder.onnx',
        'base-tokens.txt',
      ],
      sizeEstimateMb: 198,
    ),
    AiModelType.whisperSmallEn: AiModelConfig(
      type: AiModelType.whisperSmallEn,
      name: 'Whisper Small (English)',
      category: 'ASR',
      downloadUrl: '$_baseUrl/asr-models/sherpa-onnx-whisper-small.en.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-small.en.tar.bz2',
      extractedDirName: 'sherpa-onnx-whisper-small.en',
      requiredFiles: [
        'small.en-encoder.onnx',
        'small.en-decoder.onnx',
        'small.en-tokens.txt',
      ],
      sizeEstimateMb: 606,
    ),
    AiModelType.whisperSmall: AiModelConfig(
      type: AiModelType.whisperSmall,
      name: 'Whisper Small (Multilingual)',
      category: 'ASR',
      downloadUrl: '$_baseUrl/asr-models/sherpa-onnx-whisper-small.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-small.tar.bz2',
      extractedDirName: 'sherpa-onnx-whisper-small',
      requiredFiles: [
        'small-encoder.onnx',
        'small-decoder.onnx',
        'small-tokens.txt',
      ],
      sizeEstimateMb: 610,
    ),
    AiModelType.whisperMediumEn: AiModelConfig(
      type: AiModelType.whisperMediumEn,
      name: 'Whisper Medium (English)',
      category: 'ASR',
      downloadUrl: '$_baseUrl/asr-models/sherpa-onnx-whisper-medium.en.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-medium.en.tar.bz2',
      extractedDirName: 'sherpa-onnx-whisper-medium.en',
      requiredFiles: [
        'medium.en-encoder.onnx',
        'medium.en-decoder.onnx',
        'medium.en-tokens.txt',
      ],
      sizeEstimateMb: 1770,
    ),
    AiModelType.whisperMedium: AiModelConfig(
      type: AiModelType.whisperMedium,
      name: 'Whisper Medium (Multilingual)',
      category: 'ASR',
      downloadUrl: '$_baseUrl/asr-models/sherpa-onnx-whisper-medium.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-medium.tar.bz2',
      extractedDirName: 'sherpa-onnx-whisper-medium',
      requiredFiles: [
        'medium-encoder.onnx',
        'medium-decoder.onnx',
        'medium-tokens.txt',
      ],
      sizeEstimateMb: 1800,
    ),
    AiModelType.whisperLargeV3: AiModelConfig(
      type: AiModelType.whisperLargeV3,
      name: 'Whisper Large v3',
      category: 'ASR',
      downloadUrl: '$_baseUrl/asr-models/sherpa-onnx-whisper-large-v3.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-large-v3.tar.bz2',
      extractedDirName: 'sherpa-onnx-whisper-large-v3',
      requiredFiles: [
        'large-v3-encoder.onnx',
        'large-v3-decoder.onnx',
        'large-v3-tokens.txt',
      ],
      sizeEstimateMb: 1020,
    ),
    AiModelType.whisperTurbo: AiModelConfig(
      type: AiModelType.whisperTurbo,
      name: 'Whisper Turbo',
      category: 'ASR',
      downloadUrl: '$_baseUrl/asr-models/sherpa-onnx-whisper-turbo.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-turbo.tar.bz2',
      extractedDirName: 'sherpa-onnx-whisper-turbo',
      requiredFiles: [
        'turbo-encoder.onnx',
        'turbo-decoder.onnx',
        'turbo-tokens.txt',
      ],
      sizeEstimateMb: 538,
    ),
    AiModelType.whisperDistilLargeV3: AiModelConfig(
      type: AiModelType.whisperDistilLargeV3,
      name: 'Whisper Distil Large v3',
      category: 'ASR',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-whisper-distil-large-v3.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-distil-large-v3.tar.bz2',
      extractedDirName: 'sherpa-onnx-whisper-distil-large-v3',
      requiredFiles: [
        'distil-large-v3-encoder.onnx',
        'distil-large-v3-decoder.onnx',
      ],
      sizeEstimateMb: 505,
    ),
    AiModelType.whisperDistilSmallEn: AiModelConfig(
      type: AiModelType.whisperDistilSmallEn,
      name: 'Whisper Distil Small (English)',
      category: 'ASR',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-whisper-distil-small.en.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-distil-small.en.tar.bz2',
      extractedDirName: 'sherpa-onnx-whisper-distil-small.en',
      requiredFiles: [
        'distil-small.en-encoder.onnx',
        'distil-small.en-decoder.onnx',
      ],
      sizeEstimateMb: 433,
    ),

    // ============================================================
    // ASR MODELS - MOONSHINE
    // ============================================================
    AiModelType.moonshineTinyInt8: AiModelConfig(
      type: AiModelType.moonshineTinyInt8,
      name: 'Moonshine Tiny INT8',
      category: 'ASR',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-moonshine-tiny-en-int8.tar.bz2',
      archiveName: 'sherpa-onnx-moonshine-tiny-en-int8.tar.bz2',
      extractedDirName: 'sherpa-onnx-moonshine-tiny-en-int8',
      requiredFiles: [
        'preprocess.onnx',
        'encode.int8.onnx',
        'uncached_decode.int8.onnx',
        'cached_decode.int8.onnx',
      ],
      sizeEstimateMb: 103,
    ),
    AiModelType.moonshineBaseInt8: AiModelConfig(
      type: AiModelType.moonshineBaseInt8,
      name: 'Moonshine Base INT8',
      category: 'ASR',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-moonshine-base-en-int8.tar.bz2',
      archiveName: 'sherpa-onnx-moonshine-base-en-int8.tar.bz2',
      extractedDirName: 'sherpa-onnx-moonshine-base-en-int8',
      requiredFiles: [
        'preprocess.onnx',
        'encode.int8.onnx',
        'uncached_decode.int8.onnx',
        'cached_decode.int8.onnx',
      ],
      sizeEstimateMb: 239,
    ),

    // ============================================================
    // ASR MODELS - SENSEVOICE (MULTILINGUAL)
    // ============================================================
    AiModelType.senseVoiceMultilingual: AiModelConfig(
      type: AiModelType.senseVoiceMultilingual,
      name: 'SenseVoice (ZH/EN/JA/KO/YUE)',
      category: 'ASR',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2025-09-09.tar.bz2',
      archiveName: 'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2025-09-09.tar.bz2',
      extractedDirName: 'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2025-09-09',
      requiredFiles: ['model.onnx', 'tokens.txt'],
      sizeEstimateMb: 845,
    ),
    AiModelType.senseVoiceMultilingualInt8: AiModelConfig(
      type: AiModelType.senseVoiceMultilingualInt8,
      name: 'SenseVoice INT8 (ZH/EN/JA/KO/YUE)',
      category: 'ASR',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2025-09-09.tar.bz2',
      archiveName:
          'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2025-09-09.tar.bz2',
      extractedDirName:
          'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2025-09-09',
      requiredFiles: ['model.int8.onnx', 'tokens.txt'],
      sizeEstimateMb: 158,
    ),

    // ============================================================
    // ASR MODELS - STREAMING ZIPFORMER
    // ============================================================
    AiModelType.streamingZipformerEnMobile: AiModelConfig(
      type: AiModelType.streamingZipformerEnMobile,
      name: 'Streaming Zipformer Mobile (English)',
      category: 'ASR Streaming',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-streaming-zipformer-en-2023-06-26-mobile.tar.bz2',
      archiveName:
          'sherpa-onnx-streaming-zipformer-en-2023-06-26-mobile.tar.bz2',
      extractedDirName: 'sherpa-onnx-streaming-zipformer-en-2023-06-26-mobile',
      requiredFiles: [
        'encoder-epoch-99-avg-1.int8.onnx',
        'decoder-epoch-99-avg-1.onnx',
        'joiner-epoch-99-avg-1.int8.onnx',
        'tokens.txt',
      ],
      sizeEstimateMb: 291,
    ),
    AiModelType.streamingZipformerEn20M: AiModelConfig(
      type: AiModelType.streamingZipformerEn20M,
      name: 'Streaming Zipformer 20M (English)',
      category: 'ASR Streaming',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-streaming-zipformer-en-20M-2023-02-17-mobile.tar.bz2',
      archiveName:
          'sherpa-onnx-streaming-zipformer-en-20M-2023-02-17-mobile.tar.bz2',
      extractedDirName:
          'sherpa-onnx-streaming-zipformer-en-20M-2023-02-17-mobile',
      requiredFiles: [
        'encoder-epoch-99-avg-1.int8.onnx',
        'decoder-epoch-99-avg-1.int8.onnx',
        'joiner-epoch-99-avg-1.int8.onnx',
        'tokens.txt',
      ],
      sizeEstimateMb: 103,
    ),
    AiModelType.streamingZipformerBilingualZhEnMobile: AiModelConfig(
      type: AiModelType.streamingZipformerBilingualZhEnMobile,
      name: 'Streaming Zipformer Mobile (ZH-EN)',
      category: 'ASR Streaming',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-streaming-zipformer-bilingual-zh-en-2023-02-20-mobile.tar.bz2',
      archiveName:
          'sherpa-onnx-streaming-zipformer-bilingual-zh-en-2023-02-20-mobile.tar.bz2',
      extractedDirName:
          'sherpa-onnx-streaming-zipformer-bilingual-zh-en-2023-02-20-mobile',
      requiredFiles: [
        'encoder-epoch-99-avg-1.int8.onnx',
        'decoder-epoch-99-avg-1.onnx',
        'joiner-epoch-99-avg-1.int8.onnx',
        'tokens.txt',
      ],
      sizeEstimateMb: 331,
    ),
    AiModelType.streamingZipformerSmallBilingualZhEnMobile: AiModelConfig(
      type: AiModelType.streamingZipformerSmallBilingualZhEnMobile,
      name: 'Streaming Zipformer Small Mobile (ZH-EN)',
      category: 'ASR Streaming',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-streaming-zipformer-small-bilingual-zh-en-2023-02-16-mobile.tar.bz2',
      archiveName:
          'sherpa-onnx-streaming-zipformer-small-bilingual-zh-en-2023-02-16-mobile.tar.bz2',
      extractedDirName:
          'sherpa-onnx-streaming-zipformer-small-bilingual-zh-en-2023-02-16-mobile',
      requiredFiles: [
        'encoder-epoch-99-avg-1.int8.onnx',
        'decoder-epoch-99-avg-1.onnx',
        'joiner-epoch-99-avg-1.int8.onnx',
        'tokens.txt',
      ],
      sizeEstimateMb: 341,
    ),
    AiModelType.streamingZipformerMultiZhHansInt8: AiModelConfig(
      type: AiModelType.streamingZipformerMultiZhHansInt8,
      name: 'Streaming Zipformer INT8 (Chinese)',
      category: 'ASR Streaming',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-streaming-zipformer-ctc-multi-zh-hans-int8-2023-12-13.tar.bz2',
      archiveName:
          'sherpa-onnx-streaming-zipformer-ctc-multi-zh-hans-int8-2023-12-13.tar.bz2',
      extractedDirName:
          'sherpa-onnx-streaming-zipformer-ctc-multi-zh-hans-int8-2023-12-13',
      requiredFiles: ['model.int8.onnx', 'tokens.txt'],
      sizeEstimateMb: 54,
    ),
    AiModelType.streamingZipformerEsKroko: AiModelConfig(
      type: AiModelType.streamingZipformerEsKroko,
      name: 'Streaming Zipformer Kroko (Spanish)',
      category: 'ASR Streaming',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-streaming-zipformer-es-kroko-2025-08-06.tar.bz2',
      archiveName:
          'sherpa-onnx-streaming-zipformer-es-kroko-2025-08-06.tar.bz2',
      extractedDirName: 'sherpa-onnx-streaming-zipformer-es-kroko-2025-08-06',
      requiredFiles: [
        'encoder.onnx',
        'decoder.onnx',
        'joiner.onnx',
        'tokens.txt',
      ],
      sizeEstimateMb: 119,
    ),
    AiModelType.streamingZipformer8Lang: AiModelConfig(
      type: AiModelType.streamingZipformer8Lang,
      name: 'Streaming Zipformer 8-Lang',
      category: 'ASR Streaming',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-streaming-zipformer-ar_en_id_ja_ru_th_vi_zh-2025-02-10.tar.bz2',
      archiveName:
          'sherpa-onnx-streaming-zipformer-ar_en_id_ja_ru_th_vi_zh-2025-02-10.tar.bz2',
      extractedDirName:
          'sherpa-onnx-streaming-zipformer-ar_en_id_ja_ru_th_vi_zh-2025-02-10',
      requiredFiles: [
        'encoder.onnx',
        'decoder.onnx',
        'joiner.onnx',
        'tokens.txt',
      ],
      sizeEstimateMb: 247,
    ),

    // ============================================================
    // ASR MODELS - NEMO
    // ============================================================
    AiModelType.nemoConformerSmallEn: AiModelConfig(
      type: AiModelType.nemoConformerSmallEn,
      name: 'NeMo Conformer Small (English)',
      category: 'ASR',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-nemo-ctc-en-conformer-small.tar.bz2',
      archiveName: 'sherpa-onnx-nemo-ctc-en-conformer-small.tar.bz2',
      extractedDirName: 'sherpa-onnx-nemo-ctc-en-conformer-small',
      requiredFiles: ['model.onnx', 'tokens.txt'],
      sizeEstimateMb: 73,
    ),
    AiModelType.nemoFastConformerMultiInt8: AiModelConfig(
      type: AiModelType.nemoFastConformerMultiInt8,
      name: 'NeMo Fast Conformer INT8 (10 Lang)',
      category: 'ASR',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-nemo-fast-conformer-ctc-be-de-en-es-fr-hr-it-pl-ru-uk-20k-int8.tar.bz2',
      archiveName:
          'sherpa-onnx-nemo-fast-conformer-ctc-be-de-en-es-fr-hr-it-pl-ru-uk-20k-int8.tar.bz2',
      extractedDirName:
          'sherpa-onnx-nemo-fast-conformer-ctc-be-de-en-es-fr-hr-it-pl-ru-uk-20k-int8',
      requiredFiles: ['model.int8.onnx', 'tokens.txt'],
      sizeEstimateMb: 98,
    ),
    AiModelType.nemoCanary180mInt8: AiModelConfig(
      type: AiModelType.nemoCanary180mInt8,
      name: 'NeMo Canary 180M INT8 (EN/ES/DE/FR)',
      category: 'ASR',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-nemo-canary-180m-flash-en-es-de-fr-int8.tar.bz2',
      archiveName:
          'sherpa-onnx-nemo-canary-180m-flash-en-es-de-fr-int8.tar.bz2',
      extractedDirName: 'sherpa-onnx-nemo-canary-180m-flash-en-es-de-fr-int8',
      requiredFiles: ['model.int8.onnx', 'tokens.txt'],
      sizeEstimateMb: 147,
    ),
    AiModelType.nemoStreamingFastConformerInt8: AiModelConfig(
      type: AiModelType.nemoStreamingFastConformerInt8,
      name: 'NeMo Streaming Fast Conformer INT8 (English)',
      category: 'ASR Streaming',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-nemo-streaming-fast-conformer-ctc-en-80ms-int8.tar.bz2',
      archiveName:
          'sherpa-onnx-nemo-streaming-fast-conformer-ctc-en-80ms-int8.tar.bz2',
      extractedDirName:
          'sherpa-onnx-nemo-streaming-fast-conformer-ctc-en-80ms-int8',
      requiredFiles: ['model.int8.onnx', 'tokens.txt'],
      sizeEstimateMb: 95,
    ),

    // ============================================================
    // ASR MODELS - DOLPHIN MULTILINGUAL
    // ============================================================
    AiModelType.dolphinBaseMultiInt8: AiModelConfig(
      type: AiModelType.dolphinBaseMultiInt8,
      name: 'Dolphin Base INT8 (Multilingual)',
      category: 'ASR',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-dolphin-base-ctc-multi-lang-int8-2025-04-02.tar.bz2',
      archiveName:
          'sherpa-onnx-dolphin-base-ctc-multi-lang-int8-2025-04-02.tar.bz2',
      extractedDirName:
          'sherpa-onnx-dolphin-base-ctc-multi-lang-int8-2025-04-02',
      requiredFiles: ['model.int8.onnx', 'tokens.txt'],
      sizeEstimateMb: 77,
    ),
    AiModelType.dolphinSmallMultiInt8: AiModelConfig(
      type: AiModelType.dolphinSmallMultiInt8,
      name: 'Dolphin Small INT8 (Multilingual)',
      category: 'ASR',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-dolphin-small-ctc-multi-lang-int8-2025-04-02.tar.bz2',
      archiveName:
          'sherpa-onnx-dolphin-small-ctc-multi-lang-int8-2025-04-02.tar.bz2',
      extractedDirName:
          'sherpa-onnx-dolphin-small-ctc-multi-lang-int8-2025-04-02',
      requiredFiles: ['model.int8.onnx', 'tokens.txt'],
      sizeEstimateMb: 183,
    ),

    // ============================================================
    // ASR MODELS - ZIPFORMER OFFLINE
    // ============================================================
    AiModelType.zipformerSmallEn: AiModelConfig(
      type: AiModelType.zipformerSmallEn,
      name: 'Zipformer Small (English)',
      category: 'ASR',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-zipformer-small-en-2023-06-26.tar.bz2',
      archiveName: 'sherpa-onnx-zipformer-small-en-2023-06-26.tar.bz2',
      extractedDirName: 'sherpa-onnx-zipformer-small-en-2023-06-26',
      requiredFiles: [
        'encoder-epoch-99-avg-1.onnx',
        'decoder-epoch-99-avg-1.onnx',
        'joiner-epoch-99-avg-1.onnx',
        'tokens.txt',
      ],
      sizeEstimateMb: 107,
    ),
    AiModelType.zipformerEnPunctCase: AiModelConfig(
      type: AiModelType.zipformerEnPunctCase,
      name: 'Zipformer Punct Case (English)',
      category: 'ASR',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-zipformer-en-libriheavy-20230830-small-punct-case.tar.bz2',
      archiveName:
          'sherpa-onnx-zipformer-en-libriheavy-20230830-small-punct-case.tar.bz2',
      extractedDirName:
          'sherpa-onnx-zipformer-en-libriheavy-20230830-small-punct-case',
      requiredFiles: [
        'encoder-epoch-99-avg-1.onnx',
        'decoder-epoch-99-avg-1.onnx',
        'joiner-epoch-99-avg-1.onnx',
        'tokens.txt',
      ],
      sizeEstimateMb: 296,
    ),
    AiModelType.zipformerGigaspeech: AiModelConfig(
      type: AiModelType.zipformerGigaspeech,
      name: 'Zipformer Gigaspeech (English)',
      category: 'ASR',
      downloadUrl:
          '$_baseUrl/asr-models/sherpa-onnx-zipformer-gigaspeech-2023-12-12.tar.bz2',
      archiveName: 'sherpa-onnx-zipformer-gigaspeech-2023-12-12.tar.bz2',
      extractedDirName: 'sherpa-onnx-zipformer-gigaspeech-2023-12-12',
      requiredFiles: [
        'encoder-epoch-99-avg-1.onnx',
        'decoder-epoch-99-avg-1.onnx',
        'joiner-epoch-99-avg-1.onnx',
        'tokens.txt',
      ],
      sizeEstimateMb: 293,
    ),

    // ============================================================
    // VAD MODELS
    // ============================================================
    AiModelType.sileroVad: AiModelConfig(
      type: AiModelType.sileroVad,
      name: 'Silero VAD',
      category: 'VAD',
      downloadUrl: '$_baseUrl/asr-models/silero_vad.onnx',
      archiveName: 'silero_vad.onnx',
      extractedDirName: 'silero-vad',
      requiredFiles: ['silero_vad.onnx'],
      sizeEstimateMb: 2,
      isArchive: false,
    ),

    // ============================================================
    // SPEAKER RECOGNITION MODELS
    // ============================================================
    AiModelType.speakerCampplusEn: AiModelConfig(
      type: AiModelType.speakerCampplusEn,
      name: '3D-Speaker CAM++ (English)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/3dspeaker_speech_campplus_sv_en_voxceleb_16k.onnx',
      archiveName: '3dspeaker_speech_campplus_sv_en_voxceleb_16k.onnx',
      extractedDirName: 'speaker-campplus-en',
      requiredFiles: ['3dspeaker_speech_campplus_sv_en_voxceleb_16k.onnx'],
      sizeEstimateMb: 28,
      isArchive: false,
    ),
    AiModelType.speakerCampplusZh: AiModelConfig(
      type: AiModelType.speakerCampplusZh,
      name: '3D-Speaker CAM++ (Chinese)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/3dspeaker_speech_campplus_sv_zh-cn_16k-common.onnx',
      archiveName: '3dspeaker_speech_campplus_sv_zh-cn_16k-common.onnx',
      extractedDirName: 'speaker-campplus-zh',
      requiredFiles: ['3dspeaker_speech_campplus_sv_zh-cn_16k-common.onnx'],
      sizeEstimateMb: 27,
      isArchive: false,
    ),
    AiModelType.speakerCampplusZhEnAdvanced: AiModelConfig(
      type: AiModelType.speakerCampplusZhEnAdvanced,
      name: '3D-Speaker CAM++ (ZH-EN Advanced)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/3dspeaker_speech_campplus_sv_zh_en_16k-common_advanced.onnx',
      archiveName:
          '3dspeaker_speech_campplus_sv_zh_en_16k-common_advanced.onnx',
      extractedDirName: 'speaker-campplus-zh-en',
      requiredFiles: [
        '3dspeaker_speech_campplus_sv_zh_en_16k-common_advanced.onnx',
      ],
      sizeEstimateMb: 27,
      isArchive: false,
    ),
    AiModelType.speakerEres2netv2Zh: AiModelConfig(
      type: AiModelType.speakerEres2netv2Zh,
      name: '3D-Speaker ERes2NetV2 (Chinese)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/3dspeaker_speech_eres2netv2_sv_zh-cn_16k-common.onnx',
      archiveName: '3dspeaker_speech_eres2netv2_sv_zh-cn_16k-common.onnx',
      extractedDirName: 'speaker-eres2netv2-zh',
      requiredFiles: ['3dspeaker_speech_eres2netv2_sv_zh-cn_16k-common.onnx'],
      sizeEstimateMb: 68,
      isArchive: false,
    ),
    AiModelType.speakerEres2netBase200kZh: AiModelConfig(
      type: AiModelType.speakerEres2netBase200kZh,
      name: '3D-Speaker ERes2Net Base 200k (Chinese)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/3dspeaker_speech_eres2net_base_200k_sv_zh-cn_16k-common.onnx',
      archiveName:
          '3dspeaker_speech_eres2net_base_200k_sv_zh-cn_16k-common.onnx',
      extractedDirName: 'speaker-eres2net-base-200k-zh',
      requiredFiles: [
        '3dspeaker_speech_eres2net_base_200k_sv_zh-cn_16k-common.onnx',
      ],
      sizeEstimateMb: 38,
      isArchive: false,
    ),
    AiModelType.speakerEres2netBase3dspeakerZh: AiModelConfig(
      type: AiModelType.speakerEres2netBase3dspeakerZh,
      name: '3D-Speaker ERes2Net Base (Chinese)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/3dspeaker_speech_eres2net_base_sv_zh-cn_3dspeaker_16k.onnx',
      archiveName: '3dspeaker_speech_eres2net_base_sv_zh-cn_3dspeaker_16k.onnx',
      extractedDirName: 'speaker-eres2net-base-zh',
      requiredFiles: [
        '3dspeaker_speech_eres2net_base_sv_zh-cn_3dspeaker_16k.onnx',
      ],
      sizeEstimateMb: 38,
      isArchive: false,
    ),
    AiModelType.speakerEres2netLarge3dspeakerZh: AiModelConfig(
      type: AiModelType.speakerEres2netLarge3dspeakerZh,
      name: '3D-Speaker ERes2Net Large (Chinese)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/3dspeaker_speech_eres2net_large_sv_zh-cn_3dspeaker_16k.onnx',
      archiveName:
          '3dspeaker_speech_eres2net_large_sv_zh-cn_3dspeaker_16k.onnx',
      extractedDirName: 'speaker-eres2net-large-zh',
      requiredFiles: [
        '3dspeaker_speech_eres2net_large_sv_zh-cn_3dspeaker_16k.onnx',
      ],
      sizeEstimateMb: 111,
      isArchive: false,
    ),
    AiModelType.speakerEres2netEn: AiModelConfig(
      type: AiModelType.speakerEres2netEn,
      name: '3D-Speaker ERes2Net (English)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/3dspeaker_speech_eres2net_sv_en_voxceleb_16k.onnx',
      archiveName: '3dspeaker_speech_eres2net_sv_en_voxceleb_16k.onnx',
      extractedDirName: 'speaker-eres2net-en',
      requiredFiles: ['3dspeaker_speech_eres2net_sv_en_voxceleb_16k.onnx'],
      sizeEstimateMb: 25,
      isArchive: false,
    ),
    AiModelType.speakerEres2netZh: AiModelConfig(
      type: AiModelType.speakerEres2netZh,
      name: '3D-Speaker ERes2Net (Chinese)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/3dspeaker_speech_eres2net_sv_zh-cn_16k-common.onnx',
      archiveName: '3dspeaker_speech_eres2net_sv_zh-cn_16k-common.onnx',
      extractedDirName: 'speaker-eres2net-zh',
      requiredFiles: ['3dspeaker_speech_eres2net_sv_zh-cn_16k-common.onnx'],
      sizeEstimateMb: 210,
      isArchive: false,
    ),
    AiModelType.speakerNemoSpeakernet: AiModelConfig(
      type: AiModelType.speakerNemoSpeakernet,
      name: 'NeMo SpeakerNet (English)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/nemo_en_speakerverification_speakernet.onnx',
      archiveName: 'nemo_en_speakerverification_speakernet.onnx',
      extractedDirName: 'speaker-nemo-speakernet',
      requiredFiles: ['nemo_en_speakerverification_speakernet.onnx'],
      sizeEstimateMb: 22,
      isArchive: false,
    ),
    AiModelType.speakerNemoTitanetLarge: AiModelConfig(
      type: AiModelType.speakerNemoTitanetLarge,
      name: 'NeMo TitaNet Large (English)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/nemo_en_titanet_large.onnx',
      archiveName: 'nemo_en_titanet_large.onnx',
      extractedDirName: 'speaker-nemo-titanet-large',
      requiredFiles: ['nemo_en_titanet_large.onnx'],
      sizeEstimateMb: 97,
      isArchive: false,
    ),
    AiModelType.speakerNemoTitanetSmall: AiModelConfig(
      type: AiModelType.speakerNemoTitanetSmall,
      name: 'NeMo TitaNet Small (English)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/nemo_en_titanet_small.onnx',
      archiveName: 'nemo_en_titanet_small.onnx',
      extractedDirName: 'speaker-nemo-titanet-small',
      requiredFiles: ['nemo_en_titanet_small.onnx'],
      sizeEstimateMb: 38,
      isArchive: false,
    ),
    AiModelType.wespeakerCampplusEn: AiModelConfig(
      type: AiModelType.wespeakerCampplusEn,
      name: 'WeSpeaker CAM++ (English)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/wespeaker_en_voxceleb_CAM++.onnx',
      archiveName: 'wespeaker_en_voxceleb_CAM++.onnx',
      extractedDirName: 'wespeaker-campp-en',
      requiredFiles: ['wespeaker_en_voxceleb_CAM++.onnx'],
      sizeEstimateMb: 28,
      isArchive: false,
    ),
    AiModelType.wespeakerCampplusLmEn: AiModelConfig(
      type: AiModelType.wespeakerCampplusLmEn,
      name: 'WeSpeaker CAM++ LM (English)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/wespeaker_en_voxceleb_CAM++_LM.onnx',
      archiveName: 'wespeaker_en_voxceleb_CAM++_LM.onnx',
      extractedDirName: 'wespeaker-campp-lm-en',
      requiredFiles: ['wespeaker_en_voxceleb_CAM++_LM.onnx'],
      sizeEstimateMb: 28,
      isArchive: false,
    ),
    AiModelType.wespeakerResnet152En: AiModelConfig(
      type: AiModelType.wespeakerResnet152En,
      name: 'WeSpeaker ResNet152 LM (English)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/wespeaker_en_voxceleb_resnet152_LM.onnx',
      archiveName: 'wespeaker_en_voxceleb_resnet152_LM.onnx',
      extractedDirName: 'wespeaker-resnet152-en',
      requiredFiles: ['wespeaker_en_voxceleb_resnet152_LM.onnx'],
      sizeEstimateMb: 76,
      isArchive: false,
    ),
    AiModelType.wespeakerResnet221En: AiModelConfig(
      type: AiModelType.wespeakerResnet221En,
      name: 'WeSpeaker ResNet221 LM (English)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/wespeaker_en_voxceleb_resnet221_LM.onnx',
      archiveName: 'wespeaker_en_voxceleb_resnet221_LM.onnx',
      extractedDirName: 'wespeaker-resnet221-en',
      requiredFiles: ['wespeaker_en_voxceleb_resnet221_LM.onnx'],
      sizeEstimateMb: 91,
      isArchive: false,
    ),
    AiModelType.wespeakerResnet293En: AiModelConfig(
      type: AiModelType.wespeakerResnet293En,
      name: 'WeSpeaker ResNet293 LM (English)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/wespeaker_en_voxceleb_resnet293_LM.onnx',
      archiveName: 'wespeaker_en_voxceleb_resnet293_LM.onnx',
      extractedDirName: 'wespeaker-resnet293-en',
      requiredFiles: ['wespeaker_en_voxceleb_resnet293_LM.onnx'],
      sizeEstimateMb: 109,
      isArchive: false,
    ),
    AiModelType.wespeakerResnet34En: AiModelConfig(
      type: AiModelType.wespeakerResnet34En,
      name: 'WeSpeaker ResNet34 (English)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/wespeaker_en_voxceleb_resnet34.onnx',
      archiveName: 'wespeaker_en_voxceleb_resnet34.onnx',
      extractedDirName: 'wespeaker-resnet34-en',
      requiredFiles: ['wespeaker_en_voxceleb_resnet34.onnx'],
      sizeEstimateMb: 25,
      isArchive: false,
    ),
    AiModelType.wespeakerResnet34LmEn: AiModelConfig(
      type: AiModelType.wespeakerResnet34LmEn,
      name: 'WeSpeaker ResNet34 LM (English)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/wespeaker_en_voxceleb_resnet34_LM.onnx',
      archiveName: 'wespeaker_en_voxceleb_resnet34_LM.onnx',
      extractedDirName: 'wespeaker-resnet34-lm-en',
      requiredFiles: ['wespeaker_en_voxceleb_resnet34_LM.onnx'],
      sizeEstimateMb: 25,
      isArchive: false,
    ),
    AiModelType.wespeakerResnet34Zh: AiModelConfig(
      type: AiModelType.wespeakerResnet34Zh,
      name: 'WeSpeaker ResNet34 (Chinese)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/wespeaker_zh_cnceleb_resnet34.onnx',
      archiveName: 'wespeaker_zh_cnceleb_resnet34.onnx',
      extractedDirName: 'wespeaker-resnet34-zh',
      requiredFiles: ['wespeaker_zh_cnceleb_resnet34.onnx'],
      sizeEstimateMb: 25,
      isArchive: false,
    ),
    AiModelType.wespeakerResnet34LmZh: AiModelConfig(
      type: AiModelType.wespeakerResnet34LmZh,
      name: 'WeSpeaker ResNet34 LM (Chinese)',
      category: 'Speaker ID',
      downloadUrl:
          '$_baseUrl/speaker-recongition-models/wespeaker_zh_cnceleb_resnet34_LM.onnx',
      archiveName: 'wespeaker_zh_cnceleb_resnet34_LM.onnx',
      extractedDirName: 'wespeaker-resnet34-lm-zh',
      requiredFiles: ['wespeaker_zh_cnceleb_resnet34_LM.onnx'],
      sizeEstimateMb: 25,
      isArchive: false,
    ),

    // ============================================================
    // AUDIO TAGGING MODELS
    // ============================================================
    AiModelType.audioTaggingCedBase: AiModelConfig(
      type: AiModelType.audioTaggingCedBase,
      name: 'Audio Tagging CED Base',
      category: 'Audio Tagging',
      downloadUrl:
          '$_baseUrl/audio-tagging-models/sherpa-onnx-ced-base-audio-tagging-2024-04-19.tar.bz2',
      archiveName: 'sherpa-onnx-ced-base-audio-tagging-2024-04-19.tar.bz2',
      extractedDirName: 'sherpa-onnx-ced-base-audio-tagging-2024-04-19',
      requiredFiles: ['model.onnx', 'class_labels_indices.csv'],
      sizeEstimateMb: 369,
    ),
    AiModelType.audioTaggingCedMini: AiModelConfig(
      type: AiModelType.audioTaggingCedMini,
      name: 'Audio Tagging CED Mini',
      category: 'Audio Tagging',
      downloadUrl:
          '$_baseUrl/audio-tagging-models/sherpa-onnx-ced-mini-audio-tagging-2024-04-19.tar.bz2',
      archiveName: 'sherpa-onnx-ced-mini-audio-tagging-2024-04-19.tar.bz2',
      extractedDirName: 'sherpa-onnx-ced-mini-audio-tagging-2024-04-19',
      requiredFiles: ['model.onnx', 'class_labels_indices.csv'],
      sizeEstimateMb: 46,
    ),
    AiModelType.audioTaggingCedSmall: AiModelConfig(
      type: AiModelType.audioTaggingCedSmall,
      name: 'Audio Tagging CED Small',
      category: 'Audio Tagging',
      downloadUrl:
          '$_baseUrl/audio-tagging-models/sherpa-onnx-ced-small-audio-tagging-2024-04-19.tar.bz2',
      archiveName: 'sherpa-onnx-ced-small-audio-tagging-2024-04-19.tar.bz2',
      extractedDirName: 'sherpa-onnx-ced-small-audio-tagging-2024-04-19',
      requiredFiles: ['model.onnx', 'class_labels_indices.csv'],
      sizeEstimateMb: 97,
    ),
    AiModelType.audioTaggingCedTiny: AiModelConfig(
      type: AiModelType.audioTaggingCedTiny,
      name: 'Audio Tagging CED Tiny',
      category: 'Audio Tagging',
      downloadUrl:
          '$_baseUrl/audio-tagging-models/sherpa-onnx-ced-tiny-audio-tagging-2024-04-19.tar.bz2',
      archiveName: 'sherpa-onnx-ced-tiny-audio-tagging-2024-04-19.tar.bz2',
      extractedDirName: 'sherpa-onnx-ced-tiny-audio-tagging-2024-04-19',
      requiredFiles: ['model.onnx', 'class_labels_indices.csv'],
      sizeEstimateMb: 27,
    ),
    AiModelType.audioTaggingZipformer: AiModelConfig(
      type: AiModelType.audioTaggingZipformer,
      name: 'Audio Tagging Zipformer',
      category: 'Audio Tagging',
      downloadUrl:
          '$_baseUrl/audio-tagging-models/sherpa-onnx-zipformer-audio-tagging-2024-04-09.tar.bz2',
      archiveName: 'sherpa-onnx-zipformer-audio-tagging-2024-04-09.tar.bz2',
      extractedDirName: 'sherpa-onnx-zipformer-audio-tagging-2024-04-09',
      requiredFiles: ['model.onnx', 'class_labels_indices.csv'],
      sizeEstimateMb: 288,
    ),
    AiModelType.audioTaggingZipformerSmall: AiModelConfig(
      type: AiModelType.audioTaggingZipformerSmall,
      name: 'Audio Tagging Zipformer Small',
      category: 'Audio Tagging',
      downloadUrl:
          '$_baseUrl/audio-tagging-models/sherpa-onnx-zipformer-small-audio-tagging-2024-04-15.tar.bz2',
      archiveName:
          'sherpa-onnx-zipformer-small-audio-tagging-2024-04-15.tar.bz2',
      extractedDirName: 'sherpa-onnx-zipformer-small-audio-tagging-2024-04-15',
      requiredFiles: ['model.onnx', 'class_labels_indices.csv'],
      sizeEstimateMb: 106,
    ),

    // ============================================================
    // KEYWORD SPOTTING MODELS
    // ============================================================
    AiModelType.kwsGigaspeechMobile: AiModelConfig(
      type: AiModelType.kwsGigaspeechMobile,
      name: 'KWS Gigaspeech Mobile (English)',
      category: 'Keyword Spotting',
      downloadUrl:
          '$_baseUrl/kws-models/sherpa-onnx-kws-zipformer-gigaspeech-3.3M-2024-01-01-mobile.tar.bz2',
      archiveName:
          'sherpa-onnx-kws-zipformer-gigaspeech-3.3M-2024-01-01-mobile.tar.bz2',
      extractedDirName:
          'sherpa-onnx-kws-zipformer-gigaspeech-3.3M-2024-01-01-mobile',
      requiredFiles: [
        'encoder-epoch-12-avg-2-chunk-16-left-64.int8.onnx',
        'decoder-epoch-12-avg-2-chunk-16-left-64.int8.onnx',
        'joiner-epoch-12-avg-2-chunk-16-left-64.int8.onnx',
        'tokens.txt',
      ],
      sizeEstimateMb: 15,
    ),
    AiModelType.kwsGigaspeech: AiModelConfig(
      type: AiModelType.kwsGigaspeech,
      name: 'KWS Gigaspeech (English)',
      category: 'Keyword Spotting',
      downloadUrl:
          '$_baseUrl/kws-models/sherpa-onnx-kws-zipformer-gigaspeech-3.3M-2024-01-01.tar.bz2',
      archiveName:
          'sherpa-onnx-kws-zipformer-gigaspeech-3.3M-2024-01-01.tar.bz2',
      extractedDirName: 'sherpa-onnx-kws-zipformer-gigaspeech-3.3M-2024-01-01',
      requiredFiles: [
        'encoder-epoch-12-avg-2-chunk-16-left-64.onnx',
        'decoder-epoch-12-avg-2-chunk-16-left-64.onnx',
        'joiner-epoch-12-avg-2-chunk-16-left-64.onnx',
        'tokens.txt',
      ],
      sizeEstimateMb: 17,
    ),
    AiModelType.kwsWenetspeechMobile: AiModelConfig(
      type: AiModelType.kwsWenetspeechMobile,
      name: 'KWS Wenetspeech Mobile (Chinese)',
      category: 'Keyword Spotting',
      downloadUrl:
          '$_baseUrl/kws-models/sherpa-onnx-kws-zipformer-wenetspeech-3.3M-2024-01-01-mobile.tar.bz2',
      archiveName:
          'sherpa-onnx-kws-zipformer-wenetspeech-3.3M-2024-01-01-mobile.tar.bz2',
      extractedDirName:
          'sherpa-onnx-kws-zipformer-wenetspeech-3.3M-2024-01-01-mobile',
      requiredFiles: [
        'encoder-epoch-12-avg-2-chunk-16-left-64.int8.onnx',
        'decoder-epoch-12-avg-2-chunk-16-left-64.int8.onnx',
        'joiner-epoch-12-avg-2-chunk-16-left-64.int8.onnx',
        'tokens.txt',
      ],
      sizeEstimateMb: 15,
    ),
    AiModelType.kwsWenetspeech: AiModelConfig(
      type: AiModelType.kwsWenetspeech,
      name: 'KWS Wenetspeech (Chinese)',
      category: 'Keyword Spotting',
      downloadUrl:
          '$_baseUrl/kws-models/sherpa-onnx-kws-zipformer-wenetspeech-3.3M-2024-01-01.tar.bz2',
      archiveName:
          'sherpa-onnx-kws-zipformer-wenetspeech-3.3M-2024-01-01.tar.bz2',
      extractedDirName: 'sherpa-onnx-kws-zipformer-wenetspeech-3.3M-2024-01-01',
      requiredFiles: [
        'encoder-epoch-12-avg-2-chunk-16-left-64.onnx',
        'decoder-epoch-12-avg-2-chunk-16-left-64.onnx',
        'joiner-epoch-12-avg-2-chunk-16-left-64.onnx',
        'tokens.txt',
      ],
      sizeEstimateMb: 31,
    ),
    AiModelType.kwsZhEn: AiModelConfig(
      type: AiModelType.kwsZhEn,
      name: 'KWS ZH-EN Bilingual',
      category: 'Keyword Spotting',
      downloadUrl:
          '$_baseUrl/kws-models/sherpa-onnx-kws-zipformer-zh-en-3M-2025-12-20.tar.bz2',
      archiveName: 'sherpa-onnx-kws-zipformer-zh-en-3M-2025-12-20.tar.bz2',
      extractedDirName: 'sherpa-onnx-kws-zipformer-zh-en-3M-2025-12-20',
      requiredFiles: ['encoder.onnx', 'decoder.onnx', 'joiner.onnx'],
      sizeEstimateMb: 31,
    ),

    // ============================================================
    // SPEECH ENHANCEMENT MODELS
    // ============================================================
    AiModelType.speechEnhancementGtcrn: AiModelConfig(
      type: AiModelType.speechEnhancementGtcrn,
      name: 'Speech Enhancement GTCRN',
      category: 'Speech Enhancement',
      downloadUrl: '$_baseUrl/speech-enhancement-models/gtcrn_simple.onnx',
      archiveName: 'gtcrn_simple.onnx',
      extractedDirName: 'speech-enhancement',
      requiredFiles: ['gtcrn_simple.onnx'],
      sizeEstimateMb: 5,
      isArchive: false,
    ),

    // ============================================================
    // SPEAKER SEGMENTATION MODELS
    // ============================================================
    AiModelType.speakerSegmentationPyannote: AiModelConfig(
      type: AiModelType.speakerSegmentationPyannote,
      name: 'Pyannote Segmentation 3.0',
      category: 'Speaker Segmentation',
      downloadUrl:
          '$_baseUrl/speaker-segmentation-models/sherpa-onnx-pyannote-segmentation-3-0.tar.bz2',
      archiveName: 'sherpa-onnx-pyannote-segmentation-3-0.tar.bz2',
      extractedDirName: 'sherpa-onnx-pyannote-segmentation-3-0',
      requiredFiles: ['model.onnx'],
      sizeEstimateMb: 10,
    ),

    // ============================================================
    // SOURCE SEPARATION MODELS
    // ============================================================
    AiModelType.spleeter2stemsFp16: AiModelConfig(
      type: AiModelType.spleeter2stemsFp16,
      name: 'Spleeter 2-Stems FP16',
      category: 'Source Separation',
      downloadUrl:
          '$_baseUrl/source-separation-models/sherpa-onnx-spleeter-2stems-fp16.tar.bz2',
      archiveName: 'sherpa-onnx-spleeter-2stems-fp16.tar.bz2',
      extractedDirName: 'sherpa-onnx-spleeter-2stems-fp16',
      requiredFiles: ['model.onnx'],
      sizeEstimateMb: 50,
    ),
    AiModelType.spleeter2stemsInt8: AiModelConfig(
      type: AiModelType.spleeter2stemsInt8,
      name: 'Spleeter 2-Stems INT8',
      category: 'Source Separation',
      downloadUrl:
          '$_baseUrl/source-separation-models/sherpa-onnx-spleeter-2stems-int8.tar.bz2',
      archiveName: 'sherpa-onnx-spleeter-2stems-int8.tar.bz2',
      extractedDirName: 'sherpa-onnx-spleeter-2stems-int8',
      requiredFiles: ['model.onnx'],
      sizeEstimateMb: 25,
    ),
    AiModelType.spleeter2stems: AiModelConfig(
      type: AiModelType.spleeter2stems,
      name: 'Spleeter 2-Stems',
      category: 'Source Separation',
      downloadUrl:
          '$_baseUrl/source-separation-models/sherpa-onnx-spleeter-2stems.tar.bz2',
      archiveName: 'sherpa-onnx-spleeter-2stems.tar.bz2',
      extractedDirName: 'sherpa-onnx-spleeter-2stems',
      requiredFiles: ['model.onnx'],
      sizeEstimateMb: 100,
    ),
    AiModelType.uvrMdxnetInst1: AiModelConfig(
      type: AiModelType.uvrMdxnetInst1,
      name: 'UVR MDX-NET Inst 1',
      category: 'Source Separation',
      downloadUrl: '$_baseUrl/source-separation-models/UVR-MDX-NET-Inst_1.onnx',
      archiveName: 'UVR-MDX-NET-Inst_1.onnx',
      extractedDirName: 'uvr-mdxnet-inst1',
      requiredFiles: ['UVR-MDX-NET-Inst_1.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnetInst2: AiModelConfig(
      type: AiModelType.uvrMdxnetInst2,
      name: 'UVR MDX-NET Inst 2',
      category: 'Source Separation',
      downloadUrl: '$_baseUrl/source-separation-models/UVR-MDX-NET-Inst_2.onnx',
      archiveName: 'UVR-MDX-NET-Inst_2.onnx',
      extractedDirName: 'uvr-mdxnet-inst2',
      requiredFiles: ['UVR-MDX-NET-Inst_2.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnetInst3: AiModelConfig(
      type: AiModelType.uvrMdxnetInst3,
      name: 'UVR MDX-NET Inst 3',
      category: 'Source Separation',
      downloadUrl: '$_baseUrl/source-separation-models/UVR-MDX-NET-Inst_3.onnx',
      archiveName: 'UVR-MDX-NET-Inst_3.onnx',
      extractedDirName: 'uvr-mdxnet-inst3',
      requiredFiles: ['UVR-MDX-NET-Inst_3.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnetInstHq1: AiModelConfig(
      type: AiModelType.uvrMdxnetInstHq1,
      name: 'UVR MDX-NET Inst HQ 1',
      category: 'Source Separation',
      downloadUrl:
          '$_baseUrl/source-separation-models/UVR-MDX-NET-Inst_HQ_1.onnx',
      archiveName: 'UVR-MDX-NET-Inst_HQ_1.onnx',
      extractedDirName: 'uvr-mdxnet-inst-hq1',
      requiredFiles: ['UVR-MDX-NET-Inst_HQ_1.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnetInstHq2: AiModelConfig(
      type: AiModelType.uvrMdxnetInstHq2,
      name: 'UVR MDX-NET Inst HQ 2',
      category: 'Source Separation',
      downloadUrl:
          '$_baseUrl/source-separation-models/UVR-MDX-NET-Inst_HQ_2.onnx',
      archiveName: 'UVR-MDX-NET-Inst_HQ_2.onnx',
      extractedDirName: 'uvr-mdxnet-inst-hq2',
      requiredFiles: ['UVR-MDX-NET-Inst_HQ_2.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnetInstHq3: AiModelConfig(
      type: AiModelType.uvrMdxnetInstHq3,
      name: 'UVR MDX-NET Inst HQ 3',
      category: 'Source Separation',
      downloadUrl:
          '$_baseUrl/source-separation-models/UVR-MDX-NET-Inst_HQ_3.onnx',
      archiveName: 'UVR-MDX-NET-Inst_HQ_3.onnx',
      extractedDirName: 'uvr-mdxnet-inst-hq3',
      requiredFiles: ['UVR-MDX-NET-Inst_HQ_3.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnetInstHq4: AiModelConfig(
      type: AiModelType.uvrMdxnetInstHq4,
      name: 'UVR MDX-NET Inst HQ 4',
      category: 'Source Separation',
      downloadUrl:
          '$_baseUrl/source-separation-models/UVR-MDX-NET-Inst_HQ_4.onnx',
      archiveName: 'UVR-MDX-NET-Inst_HQ_4.onnx',
      extractedDirName: 'uvr-mdxnet-inst-hq4',
      requiredFiles: ['UVR-MDX-NET-Inst_HQ_4.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnetInstHq5: AiModelConfig(
      type: AiModelType.uvrMdxnetInstHq5,
      name: 'UVR MDX-NET Inst HQ 5',
      category: 'Source Separation',
      downloadUrl:
          '$_baseUrl/source-separation-models/UVR-MDX-NET-Inst_HQ_5.onnx',
      archiveName: 'UVR-MDX-NET-Inst_HQ_5.onnx',
      extractedDirName: 'uvr-mdxnet-inst-hq5',
      requiredFiles: ['UVR-MDX-NET-Inst_HQ_5.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnetInstMain: AiModelConfig(
      type: AiModelType.uvrMdxnetInstMain,
      name: 'UVR MDX-NET Inst Main',
      category: 'Source Separation',
      downloadUrl:
          '$_baseUrl/source-separation-models/UVR-MDX-NET-Inst_Main.onnx',
      archiveName: 'UVR-MDX-NET-Inst_Main.onnx',
      extractedDirName: 'uvr-mdxnet-inst-main',
      requiredFiles: ['UVR-MDX-NET-Inst_Main.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnetVocFt: AiModelConfig(
      type: AiModelType.uvrMdxnetVocFt,
      name: 'UVR MDX-NET Vocal FT',
      category: 'Source Separation',
      downloadUrl: '$_baseUrl/source-separation-models/UVR-MDX-NET-Voc_FT.onnx',
      archiveName: 'UVR-MDX-NET-Voc_FT.onnx',
      extractedDirName: 'uvr-mdxnet-voc-ft',
      requiredFiles: ['UVR-MDX-NET-Voc_FT.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnetCrowdHq1: AiModelConfig(
      type: AiModelType.uvrMdxnetCrowdHq1,
      name: 'UVR MDX-NET Crowd HQ 1',
      category: 'Source Separation',
      downloadUrl:
          '$_baseUrl/source-separation-models/UVR-MDX-NET_Crowd_HQ_1.onnx',
      archiveName: 'UVR-MDX-NET_Crowd_HQ_1.onnx',
      extractedDirName: 'uvr-mdxnet-crowd-hq1',
      requiredFiles: ['UVR-MDX-NET_Crowd_HQ_1.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnet19703: AiModelConfig(
      type: AiModelType.uvrMdxnet19703,
      name: 'UVR MDXNET 1 (9703)',
      category: 'Source Separation',
      downloadUrl: '$_baseUrl/source-separation-models/UVR_MDXNET_1_9703.onnx',
      archiveName: 'UVR_MDXNET_1_9703.onnx',
      extractedDirName: 'uvr-mdxnet-1-9703',
      requiredFiles: ['UVR_MDXNET_1_9703.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnet29682: AiModelConfig(
      type: AiModelType.uvrMdxnet29682,
      name: 'UVR MDXNET 2 (9682)',
      category: 'Source Separation',
      downloadUrl: '$_baseUrl/source-separation-models/UVR_MDXNET_2_9682.onnx',
      archiveName: 'UVR_MDXNET_2_9682.onnx',
      extractedDirName: 'uvr-mdxnet-2-9682',
      requiredFiles: ['UVR_MDXNET_2_9682.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnet39662: AiModelConfig(
      type: AiModelType.uvrMdxnet39662,
      name: 'UVR MDXNET 3 (9662)',
      category: 'Source Separation',
      downloadUrl: '$_baseUrl/source-separation-models/UVR_MDXNET_3_9662.onnx',
      archiveName: 'UVR_MDXNET_3_9662.onnx',
      extractedDirName: 'uvr-mdxnet-3-9662',
      requiredFiles: ['UVR_MDXNET_3_9662.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnet9482: AiModelConfig(
      type: AiModelType.uvrMdxnet9482,
      name: 'UVR MDXNET (9482)',
      category: 'Source Separation',
      downloadUrl: '$_baseUrl/source-separation-models/UVR_MDXNET_9482.onnx',
      archiveName: 'UVR_MDXNET_9482.onnx',
      extractedDirName: 'uvr-mdxnet-9482',
      requiredFiles: ['UVR_MDXNET_9482.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnetKara: AiModelConfig(
      type: AiModelType.uvrMdxnetKara,
      name: 'UVR MDXNET Karaoke',
      category: 'Source Separation',
      downloadUrl: '$_baseUrl/source-separation-models/UVR_MDXNET_KARA.onnx',
      archiveName: 'UVR_MDXNET_KARA.onnx',
      extractedDirName: 'uvr-mdxnet-kara',
      requiredFiles: ['UVR_MDXNET_KARA.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnetKara2: AiModelConfig(
      type: AiModelType.uvrMdxnetKara2,
      name: 'UVR MDXNET Karaoke 2',
      category: 'Source Separation',
      downloadUrl: '$_baseUrl/source-separation-models/UVR_MDXNET_KARA_2.onnx',
      archiveName: 'UVR_MDXNET_KARA_2.onnx',
      extractedDirName: 'uvr-mdxnet-kara2',
      requiredFiles: ['UVR_MDXNET_KARA_2.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),
    AiModelType.uvrMdxnetMain: AiModelConfig(
      type: AiModelType.uvrMdxnetMain,
      name: 'UVR MDXNET Main',
      category: 'Source Separation',
      downloadUrl: '$_baseUrl/source-separation-models/UVR_MDXNET_Main.onnx',
      archiveName: 'UVR_MDXNET_Main.onnx',
      extractedDirName: 'uvr-mdxnet-main',
      requiredFiles: ['UVR_MDXNET_Main.onnx'],
      sizeEstimateMb: 50,
      isArchive: false,
    ),

    // ============================================================
    // TTS MODELS - ENGLISH
    // ============================================================
    AiModelType.ttsKittenMiniEn: AiModelConfig(
      type: AiModelType.ttsKittenMiniEn,
      name: 'Kitten Mini (English)',
      category: 'TTS',
      downloadUrl: '$_baseUrl/tts-models/kitten-mini-en-v0_1-fp16.tar.bz2',
      archiveName: 'kitten-mini-en-v0_1-fp16.tar.bz2',
      extractedDirName: 'kitten-mini-en-v0_1-fp16',
      requiredFiles: ['model.onnx', 'tokens.txt'],
      sizeEstimateMb: 149,
    ),
    AiModelType.ttsKittenNanoEn: AiModelConfig(
      type: AiModelType.ttsKittenNanoEn,
      name: 'Kitten Nano (English)',
      category: 'TTS',
      downloadUrl: '$_baseUrl/tts-models/kitten-nano-en-v0_2-fp16.tar.bz2',
      archiveName: 'kitten-nano-en-v0_2-fp16.tar.bz2',
      extractedDirName: 'kitten-nano-en-v0_2-fp16',
      requiredFiles: ['model.onnx', 'tokens.txt'],
      sizeEstimateMb: 25,
    ),
    AiModelType.ttsKokoroEn: AiModelConfig(
      type: AiModelType.ttsKokoroEn,
      name: 'Kokoro (English)',
      category: 'TTS',
      downloadUrl: '$_baseUrl/tts-models/kokoro-en-v0_19.tar.bz2',
      archiveName: 'kokoro-en-v0_19.tar.bz2',
      extractedDirName: 'kokoro-en-v0_19',
      requiredFiles: ['model.onnx', 'tokens.txt'],
      sizeEstimateMb: 305,
    ),
    AiModelType.ttsKokoroInt8En: AiModelConfig(
      type: AiModelType.ttsKokoroInt8En,
      name: 'Kokoro INT8 (English)',
      category: 'TTS',
      downloadUrl: '$_baseUrl/tts-models/kokoro-int8-en-v0_19.tar.bz2',
      archiveName: 'kokoro-int8-en-v0_19.tar.bz2',
      extractedDirName: 'kokoro-int8-en-v0_19',
      requiredFiles: ['model.onnx', 'tokens.txt'],
      sizeEstimateMb: 99,
    ),
    AiModelType.ttsMatchaLjspeech: AiModelConfig(
      type: AiModelType.ttsMatchaLjspeech,
      name: 'Matcha LJSpeech (English)',
      category: 'TTS',
      downloadUrl: '$_baseUrl/tts-models/matcha-icefall-en_US-ljspeech.tar.bz2',
      archiveName: 'matcha-icefall-en_US-ljspeech.tar.bz2',
      extractedDirName: 'matcha-icefall-en_US-ljspeech',
      requiredFiles: ['model.onnx', 'tokens.txt'],
      sizeEstimateMb: 73,
    ),
    AiModelType.ttsMatchaZhEn: AiModelConfig(
      type: AiModelType.ttsMatchaZhEn,
      name: 'Matcha ZH-EN Bilingual',
      category: 'TTS',
      downloadUrl: '$_baseUrl/tts-models/matcha-icefall-zh-en.tar.bz2',
      archiveName: 'matcha-icefall-zh-en.tar.bz2',
      extractedDirName: 'matcha-icefall-zh-en',
      requiredFiles: ['model.onnx', 'tokens.txt'],
      sizeEstimateMb: 75,
    ),
    AiModelType.ttsVitsCoquiLjspeech: AiModelConfig(
      type: AiModelType.ttsVitsCoquiLjspeech,
      name: 'VITS Coqui LJSpeech (English)',
      category: 'TTS',
      downloadUrl: '$_baseUrl/tts-models/vits-coqui-en-ljspeech.tar.bz2',
      archiveName: 'vits-coqui-en-ljspeech.tar.bz2',
      extractedDirName: 'vits-coqui-en-ljspeech',
      requiredFiles: ['model.onnx', 'tokens.txt', 'espeak-ng-data'],
      sizeEstimateMb: 110,
    ),
    AiModelType.ttsVitsCoquiVctk: AiModelConfig(
      type: AiModelType.ttsVitsCoquiVctk,
      name: 'VITS Coqui VCTK Multi-Speaker (English)',
      category: 'TTS',
      downloadUrl: '$_baseUrl/tts-models/vits-coqui-en-vctk.tar.bz2',
      archiveName: 'vits-coqui-en-vctk.tar.bz2',
      extractedDirName: 'vits-coqui-en-vctk',
      requiredFiles: ['model.onnx', 'tokens.txt', 'espeak-ng-data'],
      sizeEstimateMb: 117,
    ),
    AiModelType.ttsVitsMeloEn: AiModelConfig(
      type: AiModelType.ttsVitsMeloEn,
      name: 'VITS MeloTTS (English)',
      category: 'TTS',
      downloadUrl: '$_baseUrl/tts-models/vits-melo-tts-en.tar.bz2',
      archiveName: 'vits-melo-tts-en.tar.bz2',
      extractedDirName: 'vits-melo-tts-en',
      requiredFiles: ['model.onnx', 'tokens.txt', 'espeak-ng-data'],
      sizeEstimateMb: 155,
    ),
    AiModelType.ttsVitsMmsEng: AiModelConfig(
      type: AiModelType.ttsVitsMmsEng,
      name: 'VITS MMS (English)',
      category: 'TTS',
      downloadUrl: '$_baseUrl/tts-models/vits-mms-eng.tar.bz2',
      archiveName: 'vits-mms-eng.tar.bz2',
      extractedDirName: 'vits-mms-eng',
      requiredFiles: ['model.onnx', 'tokens.txt', 'espeak-ng-data'],
      sizeEstimateMb: 103,
    ),
    AiModelType.ttsVitsPiperLessacInt8: AiModelConfig(
      type: AiModelType.ttsVitsPiperLessacInt8,
      name: 'Piper Lessac INT8 (English US)',
      category: 'TTS',
      downloadUrl:
          '$_baseUrl/tts-models/vits-piper-en_US-lessac-medium-int8.tar.bz2',
      archiveName: 'vits-piper-en_US-lessac-medium-int8.tar.bz2',
      extractedDirName: 'vits-piper-en_US-lessac-medium-int8',
      requiredFiles: [
        'en_US-lessac-medium.onnx',
        'tokens.txt',
        'espeak-ng-data',
      ],
      sizeEstimateMb: 20,
    ),
    AiModelType.ttsVitsPiperRyanInt8: AiModelConfig(
      type: AiModelType.ttsVitsPiperRyanInt8,
      name: 'Piper Ryan INT8 (English US)',
      category: 'TTS',
      downloadUrl:
          '$_baseUrl/tts-models/vits-piper-en_US-ryan-medium-int8.tar.bz2',
      archiveName: 'vits-piper-en_US-ryan-medium-int8.tar.bz2',
      extractedDirName: 'vits-piper-en_US-ryan-medium-int8',
      requiredFiles: ['en_US-ryan-medium.onnx', 'tokens.txt', 'espeak-ng-data'],
      sizeEstimateMb: 20,
    ),
    AiModelType.ttsVitsPiperAmyInt8: AiModelConfig(
      type: AiModelType.ttsVitsPiperAmyInt8,
      name: 'Piper Amy INT8 (English US)',
      category: 'TTS',
      downloadUrl: '$_baseUrl/tts-models/vits-piper-en_US-amy-low-int8.tar.bz2',
      archiveName: 'vits-piper-en_US-amy-low-int8.tar.bz2',
      extractedDirName: 'vits-piper-en_US-amy-low-int8',
      requiredFiles: ['en_US-amy-low.onnx', 'tokens.txt', 'espeak-ng-data'],
      sizeEstimateMb: 20,
    ),
    AiModelType.ttsVitsPiperLibrittsInt8: AiModelConfig(
      type: AiModelType.ttsVitsPiperLibrittsInt8,
      name: 'Piper LibriTTS INT8 Multi-Speaker (English US)',
      category: 'TTS',
      downloadUrl:
          '$_baseUrl/tts-models/vits-piper-en_US-libritts-high-int8.tar.bz2',
      archiveName: 'vits-piper-en_US-libritts-high-int8.tar.bz2',
      extractedDirName: 'vits-piper-en_US-libritts-high-int8',
      requiredFiles: [
        'en_US-libritts-high.onnx',
        'tokens.txt',
        'espeak-ng-data',
      ],
      sizeEstimateMb: 35,
    ),
    AiModelType.ttsVitsPiperJoeInt8: AiModelConfig(
      type: AiModelType.ttsVitsPiperJoeInt8,
      name: 'Piper Joe INT8 (English US)',
      category: 'TTS',
      downloadUrl:
          '$_baseUrl/tts-models/vits-piper-en_US-joe-medium-int8.tar.bz2',
      archiveName: 'vits-piper-en_US-joe-medium-int8.tar.bz2',
      extractedDirName: 'vits-piper-en_US-joe-medium-int8',
      requiredFiles: ['en_US-joe-medium.onnx', 'tokens.txt', 'espeak-ng-data'],
      sizeEstimateMb: 20,
    ),
    AiModelType.ttsVitsPiperGladosInt8: AiModelConfig(
      type: AiModelType.ttsVitsPiperGladosInt8,
      name: 'Piper GLaDOS INT8 (English US)',
      category: 'TTS',
      downloadUrl:
          '$_baseUrl/tts-models/vits-piper-en_US-glados-high-int8.tar.bz2',
      archiveName: 'vits-piper-en_US-glados-high-int8.tar.bz2',
      extractedDirName: 'vits-piper-en_US-glados-high-int8',
      requiredFiles: ['en_US-glados-high.onnx', 'tokens.txt', 'espeak-ng-data'],
      sizeEstimateMb: 34,
    ),

    // ============================================================
    // TTS MODELS - SPANISH
    // ============================================================
    AiModelType.ttsVitsCoquiEsCss10: AiModelConfig(
      type: AiModelType.ttsVitsCoquiEsCss10,
      name: 'VITS Coqui CSS10 (Spanish)',
      category: 'TTS',
      downloadUrl: '$_baseUrl/tts-models/vits-coqui-es-css10.tar.bz2',
      archiveName: 'vits-coqui-es-css10.tar.bz2',
      extractedDirName: 'vits-coqui-es-css10',
      requiredFiles: ['model.onnx', 'tokens.txt', 'espeak-ng-data'],
      sizeEstimateMb: 64,
    ),
    AiModelType.ttsVitsMmsSpa: AiModelConfig(
      type: AiModelType.ttsVitsMmsSpa,
      name: 'VITS MMS (Spanish)',
      category: 'TTS',
      downloadUrl: '$_baseUrl/tts-models/vits-mms-spa.tar.bz2',
      archiveName: 'vits-mms-spa.tar.bz2',
      extractedDirName: 'vits-mms-spa',
      requiredFiles: ['model.onnx', 'tokens.txt', 'espeak-ng-data'],
      sizeEstimateMb: 103,
    ),
    AiModelType.ttsVitsPiperEsDanielaInt8: AiModelConfig(
      type: AiModelType.ttsVitsPiperEsDanielaInt8,
      name: 'Piper Daniela INT8 (Spanish AR)',
      category: 'TTS',
      downloadUrl:
          '$_baseUrl/tts-models/vits-piper-es_AR-daniela-high-int8.tar.bz2',
      archiveName: 'vits-piper-es_AR-daniela-high-int8.tar.bz2',
      extractedDirName: 'vits-piper-es_AR-daniela-high-int8',
      requiredFiles: [
        'es_AR-daniela-high.onnx',
        'tokens.txt',
        'espeak-ng-data',
      ],
      sizeEstimateMb: 33,
    ),
    AiModelType.ttsVitsPiperEsCarlfmInt8: AiModelConfig(
      type: AiModelType.ttsVitsPiperEsCarlfmInt8,
      name: 'Piper Carlfm INT8 (Spanish ES)',
      category: 'TTS',
      downloadUrl:
          '$_baseUrl/tts-models/vits-piper-es_ES-carlfm-x_low-int8.tar.bz2',
      archiveName: 'vits-piper-es_ES-carlfm-x_low-int8.tar.bz2',
      extractedDirName: 'vits-piper-es_ES-carlfm-x_low-int8',
      requiredFiles: [
        'es_ES-carlfm-x_low.onnx',
        'tokens.txt',
        'espeak-ng-data',
      ],
      sizeEstimateMb: 13,
    ),
    AiModelType.ttsVitsPiperEsDavefxInt8: AiModelConfig(
      type: AiModelType.ttsVitsPiperEsDavefxInt8,
      name: 'Piper Davefx INT8 (Spanish ES)',
      category: 'TTS',
      downloadUrl:
          '$_baseUrl/tts-models/vits-piper-es_ES-davefx-medium-int8.tar.bz2',
      archiveName: 'vits-piper-es_ES-davefx-medium-int8.tar.bz2',
      extractedDirName: 'vits-piper-es_ES-davefx-medium-int8',
      requiredFiles: [
        'es_ES-davefx-medium.onnx',
        'tokens.txt',
        'espeak-ng-data',
      ],
      sizeEstimateMb: 20,
    ),
    AiModelType.ttsVitsPiperEsGladosInt8: AiModelConfig(
      type: AiModelType.ttsVitsPiperEsGladosInt8,
      name: 'Piper GLaDOS INT8 (Spanish ES)',
      category: 'TTS',
      downloadUrl:
          '$_baseUrl/tts-models/vits-piper-es_ES-glados-medium-int8.tar.bz2',
      archiveName: 'vits-piper-es_ES-glados-medium-int8.tar.bz2',
      extractedDirName: 'vits-piper-es_ES-glados-medium-int8',
      requiredFiles: [
        'es_ES-glados-medium.onnx',
        'tokens.txt',
        'espeak-ng-data',
      ],
      sizeEstimateMb: 20,
    ),
    AiModelType.ttsVitsPiperEsMiroInt8: AiModelConfig(
      type: AiModelType.ttsVitsPiperEsMiroInt8,
      name: 'Piper Miro INT8 (Spanish ES)',
      category: 'TTS',
      downloadUrl:
          '$_baseUrl/tts-models/vits-piper-es_ES-miro-high-int8.tar.bz2',
      archiveName: 'vits-piper-es_ES-miro-high-int8.tar.bz2',
      extractedDirName: 'vits-piper-es_ES-miro-high-int8',
      requiredFiles: ['es_ES-miro-high.onnx', 'tokens.txt', 'espeak-ng-data'],
      sizeEstimateMb: 20,
    ),
    AiModelType.ttsVitsPiperEsMxAldInt8: AiModelConfig(
      type: AiModelType.ttsVitsPiperEsMxAldInt8,
      name: 'Piper Ald INT8 (Spanish MX)',
      category: 'TTS',
      downloadUrl:
          '$_baseUrl/tts-models/vits-piper-es_MX-ald-medium-int8.tar.bz2',
      archiveName: 'vits-piper-es_MX-ald-medium-int8.tar.bz2',
      extractedDirName: 'vits-piper-es_MX-ald-medium-int8',
      requiredFiles: ['es_MX-ald-medium.onnx', 'tokens.txt', 'espeak-ng-data'],
      sizeEstimateMb: 20,
    ),
    AiModelType.ttsVitsPiperEsMxClaudeInt8: AiModelConfig(
      type: AiModelType.ttsVitsPiperEsMxClaudeInt8,
      name: 'Piper Claude INT8 (Spanish MX)',
      category: 'TTS',
      downloadUrl:
          '$_baseUrl/tts-models/vits-piper-es_MX-claude-high-int8.tar.bz2',
      archiveName: 'vits-piper-es_MX-claude-high-int8.tar.bz2',
      extractedDirName: 'vits-piper-es_MX-claude-high-int8',
      requiredFiles: ['es_MX-claude-high.onnx', 'tokens.txt', 'espeak-ng-data'],
      sizeEstimateMb: 20,
    ),
  };

  /// Get model configuration by type.
  static AiModelConfig? getConfig(AiModelType type) => models[type];

  /// Get all registered models.
  static List<AiModelConfig> get allModels => models.values.toList();

  /// Get models by category.
  static List<AiModelConfig> getByCategory(String category) =>
      models.values.where((m) => m.category == category).toList();

  /// Get all available categories.
  static List<String> get categories =>
      models.values.map((m) => m.category).toSet().toList();
}
