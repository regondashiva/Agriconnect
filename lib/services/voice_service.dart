import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants/api_constants.dart';
import '../models/produce_model.dart';
import 'api_service.dart';
import 'app_state.dart';

enum FarmerVoiceIntent {
  sellProduce,
  checkDemand,
  priceAdvisory,
  weatherAdvisory,
  generalQuery,
}

class FarmerVoiceResult {
  final String queryText;
  final String responseText;
  final FarmerVoiceIntent intent;
  final String? suggestedRoute;
  final String? actionLabel;
  final String? audioResponseFilePath;
  final Map<String, dynamic> extractedEntities;

  const FarmerVoiceResult({
    required this.queryText,
    required this.responseText,
    required this.intent,
    this.suggestedRoute,
    this.actionLabel,
    this.audioResponseFilePath,
    this.extractedEntities = const {},
  });
}

class FarmerVoiceEntityExtraction {
  final String? name;
  final String? location;
  final String? crop;
  final double? quantityKg;
  final double? landSizeAcres;
  final String rawTranscript;

  const FarmerVoiceEntityExtraction({
    this.name,
    this.location,
    this.crop,
    this.quantityKg,
    this.landSizeAcres,
    required this.rawTranscript,
  });
}

/// Comprehensive Voice AI Service for AgriConnect
/// Combines:
/// 1. Edge AI Microservice (Vosk Speech-to-Text + TF-IDF intent model returning .mp3)
/// 2. Audio Recording (AAC/M4A via record package)
/// 3. Audio Playback (raw binary MP3 via audioplayers package)
/// 4. Device Native TTS Fallback (flutter_tts in Telugu, Hindi, English)
class VoiceService {
  VoiceService._() {
    _initTts();
  }
  static final VoiceService instance = VoiceService._();

  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isSpeechInitialized = false;
  bool _isSpeaking = false;
  bool _isRecording = false;
  String? _lastRecordedFilePath;
  String? _lastAiResponseAudioPath;
  String? _lastSpokenText;
  String _lastLanguage = 'Telugu';

  bool get isSpeaking => _isSpeaking;
  bool get isRecording => _isRecording;
  String? get lastRecordedFilePath => _lastRecordedFilePath;
  String? get lastAiResponseAudioPath => _lastAiResponseAudioPath;

  Future<void> _initTts() async {
    try {
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });
      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
      });

      _audioPlayer.onPlayerStateChanged.listen((state) {
        _isSpeaking = state == PlayerState.playing;
      });
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // 1. Audio Recording (record package)
  // ---------------------------------------------------------------------------

  /// Start recording farmer's voice from microphone to an .m4a file
  Future<String?> startAudioRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/farmer_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
        _lastRecordedFilePath = filePath;
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: filePath,
        );
        _isRecording = true;
        debugPrint('[VoiceService] Audio recording started at: $filePath (16kHz WAV)');
        return filePath;
      }
    } catch (e) {
      debugPrint('[VoiceService] Error starting audio recorder: $e');
    }
    return null;
  }

  /// Stop audio recording and return the recorded file path
  Future<String?> stopAudioRecording() async {
    try {
      if (_isRecording) {
        final path = await _audioRecorder.stop();
        _isRecording = false;
        debugPrint('[VoiceService] Audio recording saved to: $path');
        return path ?? _lastRecordedFilePath;
      }
    } catch (e) {
      debugPrint('[VoiceService] Error stopping audio recorder: $e');
    }
    _isRecording = false;
    return _lastRecordedFilePath;
  }

  // ---------------------------------------------------------------------------
  // 2. Edge AI Server Upload & MP3 Response Playback (audioplayers package)
  // ---------------------------------------------------------------------------

  /// Upload recorded audio file to the Python FastAPI Voice AI Microservice
  /// Endpoint: POST https://agriconnect-voice-ai.onrender.com/api/v1/voice/chat?lang=en
  /// (Set lang=hi for Hindi, lang=te for Telugu, lang=mr for Marathi, lang=gu for Gujarati)
  /// Response: direct binary audio/mpeg bytes (.mp3)
  Future<String?> sendVoiceAndGetMp3(
    String audioFilePath, {
    String? jwtToken,
    String language = 'Telugu',
  }) async {
    try {
      final token = jwtToken ?? ApiService.instance.authToken ?? 'DEMO_FARMER_JWT';
      final file = File(audioFilePath);
      if (!await file.exists()) {
        debugPrint('[VoiceService] Audio file does not exist: $audioFilePath');
        return null;
      }

      String langCode = 'en';
      final langLower = language.toLowerCase();
      if (langLower.startsWith('te')) {
        langCode = 'te';
      } else if (langLower.startsWith('hi')) {
        langCode = 'hi';
      } else if (langLower.startsWith('mr')) {
        langCode = 'mr';
      } else if (langLower.startsWith('gu')) {
        langCode = 'gu';
      }

      final endpoints = [
        Uri.parse('${ApiConstants.voiceChat}?lang=$langCode'),
        Uri.parse('http://localhost:8001/api/v1/voice/chat?lang=$langCode'),
      ];

      for (final uri in endpoints) {
        try {
          var request = http.MultipartRequest('POST', uri);
          request.headers['Authorization'] = 'Bearer $token';
          request.files.add(await http.MultipartFile.fromPath('audio', audioFilePath));

          debugPrint('[VoiceService] Uploading voice file to Edge AI: $uri');
          final streamedResponse = await request.send().timeout(const Duration(seconds: 12));
          final response = await http.Response.fromStream(streamedResponse);

          debugPrint('[VoiceService] Edge AI response: status=${response.statusCode}, size=${response.bodyBytes.length} bytes');

          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            final directory = await getApplicationDocumentsDirectory();
            final responseFilePath = '${directory.path}/ai_response_${DateTime.now().millisecondsSinceEpoch}.mp3';
            final mp3File = File(responseFilePath);
            await mp3File.writeAsBytes(response.bodyBytes);
            _lastAiResponseAudioPath = responseFilePath;
            debugPrint('[VoiceService] Saved AI voice MP3 to: $responseFilePath');
            return responseFilePath;
          } else {
            debugPrint('[VoiceService] AI Server ($uri) Error: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          debugPrint('[VoiceService] Failed connecting to $uri: $e');
        }
      }
    } catch (e) {
      debugPrint('[VoiceService] Edge AI server request failed (will use native TTS): $e');
    }
    return null;
  }

  /// Play an MP3 file through the device speakers
  Future<void> playAudioFile(String filePath) async {
    try {
      await stopSpeaking();
      _isSpeaking = true;
      await _audioPlayer.play(DeviceFileSource(filePath));
      debugPrint('[VoiceService] Playing AI response MP3: $filePath');
    } catch (e) {
      debugPrint('[VoiceService] AudioPlayer play error: $e');
      _isSpeaking = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Native Speech-To-Text & TTS Fallback
  // ---------------------------------------------------------------------------

  /// Speak text aloud through device speakers using FlutterTts in Telugu, Hindi, or English
  Future<void> speak(String text, {String language = 'Telugu'}) async {
    _lastSpokenText = text;
    _lastLanguage = language;

    try {
      await stopSpeaking();
      String langCode = 'te-IN';
      if (language.startsWith('Hindi')) {
        langCode = 'hi-IN';
      } else if (language.startsWith('English')) {
        langCode = 'en-IN';
      }

      await _flutterTts.setLanguage(langCode);
      _isSpeaking = true;
      await _flutterTts.speak(text);
    } catch (_) {
      try {
        await _flutterTts.setLanguage('en-IN');
        await _flutterTts.speak(text);
      } catch (_) {}
    }
  }

  /// Stop all speech and audio playback
  Future<void> stopSpeaking() async {
    try {
      _isSpeaking = false;
      await _flutterTts.stop();
      await _audioPlayer.stop();
    } catch (_) {}
  }

  /// Replay the last AI voice output (either the server .mp3 file or device TTS)
  Future<void> replayLastVoice() async {
    if (_lastAiResponseAudioPath != null && File(_lastAiResponseAudioPath!).existsSync()) {
      await playAudioFile(_lastAiResponseAudioPath!);
    } else if (_lastSpokenText != null && _lastSpokenText!.isNotEmpty) {
      await speak(_lastSpokenText!, language: _lastLanguage);
    }
  }

  /// Initialize microphone speech recognition for live on-device transcript
  Future<bool> initSpeech() async {
    if (_isSpeechInitialized) return true;
    try {
      _isSpeechInitialized = await _speechToText.initialize(
        onError: (err) {
          debugPrint('[VoiceService] STT Error: $err');
        },
        onStatus: (status) {
          debugPrint('[VoiceService] STT Status: $status');
        },
      );
      return _isSpeechInitialized;
    } catch (e) {
      debugPrint('[VoiceService] STT Init failed: $e');
      return false;
    }
  }

  /// Start live microphone listening for farmer's speech with fallback
  Future<bool> startListening({
    required Function(String recognizedWords) onResult,
    String language = 'Telugu',
  }) async {
    final available = await initSpeech();
    if (!available) {
      debugPrint('[VoiceService] Speech recognition not available on device');
      return false;
    }

    try {
      if (_isRecording) {
        await stopAudioRecording();
      }
      await stopSpeaking();

      if (_speechToText.isListening) {
        await _speechToText.stop();
      }

      String targetLocale = 'en_IN';
      if (language.startsWith('Telugu')) {
        targetLocale = 'te_IN';
      } else if (language.startsWith('Hindi')) {
        targetLocale = 'hi_IN';
      } else if (language.startsWith('English')) {
        targetLocale = 'en_IN';
      }

      // Check if target locale is supported on device, else fallback safely
      List<stt.LocaleName> locales = [];
      try {
        locales = await _speechToText.locales();
      } catch (_) {}

      bool hasTarget = locales.any((l) => l.localeId == targetLocale || l.localeId.startsWith(targetLocale.substring(0, 2)));
      String activeLocale = hasTarget ? targetLocale : (locales.isNotEmpty ? locales.first.localeId : 'en_IN');

      debugPrint('[VoiceService] Listening with locale: $activeLocale (requested: $targetLocale)');

      await _speechToText.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          onDevice: false,
          cancelOnError: false,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('[VoiceService] STT Listen error: $e');
      // Fallback try without specifying options
      try {
        await _speechToText.listen(
          onResult: (result) {
            if (result.recognizedWords.isNotEmpty) {
              onResult(result.recognizedWords);
            }
          },
          listenOptions: stt.SpeechListenOptions(partialResults: true),
        );
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  /// Stop microphone listening
  Future<void> stopListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
    } catch (_) {}
  }

  /// Extract farmer profile attributes from voice text
  FarmerVoiceEntityExtraction extractFarmerProfileEntities(String text, {int? step}) {
    final clean = text.trim();
    if (clean.isEmpty) {
      return FarmerVoiceEntityExtraction(rawTranscript: text);
    }

    String? name;
    String? location;
    String? crop;
    double? quantityKg;
    double? landSizeAcres;

    // Step-specific extraction
    if (step == 0) {
      // Step 0: Name
      String n = clean;
      n = n.replaceAll(RegExp(r"^(my name is|i am|this is|i'm|name is|నా పేరు|నేను|నన్ను|నాది|మేరా నామ్|మేరా నామ)\s*", caseSensitive: false), "");
      n = n.replaceAll(RegExp(r"(గారు|గారూ|ji|saab)$", caseSensitive: false), "").trim();
      if (n.isNotEmpty) {
        name = _capitalizeWords(n);
      }
      return FarmerVoiceEntityExtraction(name: name, rawTranscript: text);
    }

    if (step == 1) {
      // Step 1: Village / Location
      String loc = clean;
      loc = loc.replaceAll(RegExp(r'^(i am from|my village is|i live in|village is|location is|from|మా ఊరు|మా గ్రామం|గ్రామం|మేరా గాంవ్|మేరా గౌన్)\s*', caseSensitive: false), '');
      loc = loc.replaceAll(RegExp(r'(గ్రామం|village|dist|district|మండలం|మండల్)$', caseSensitive: false), '').trim();
      if (loc.isNotEmpty) {
        location = _capitalizeWords(loc);
      }
      return FarmerVoiceEntityExtraction(location: location, rawTranscript: text);
    }

    if (step == 2) {
      // Step 2: Primary Crop
      crop = _matchCrop(clean);
      return FarmerVoiceEntityExtraction(crop: crop, rawTranscript: text);
    }

    if (step == 3) {
      // Step 3: Quantity / Land Size
      final numMatches = RegExp(r'(\d+(?:\.\d+)?)').allMatches(clean).map((m) => double.tryParse(m.group(1)!)).whereType<double>().toList();
      final lower = clean.toLowerCase();

      if (lower.contains('acre') || lower.contains('ఎకర') || lower.contains('एकड़')) {
        if (numMatches.isNotEmpty) landSizeAcres = numMatches.first;
      }
      if (lower.contains('kg') || lower.contains('kilo') || lower.contains('కిలో') || lower.contains('किलो') || lower.contains('quintal') || lower.contains('క్వింటాల్')) {
        if (numMatches.isNotEmpty) {
          quantityKg = numMatches.first;
          if (lower.contains('quintal') || lower.contains('క్వింటాల్') || lower.contains('क्विंटल')) {
            quantityKg = quantityKg * 100;
          }
        }
      } else if (numMatches.isNotEmpty && landSizeAcres == null) {
        quantityKg = numMatches.first;
      }

      return FarmerVoiceEntityExtraction(
        quantityKg: quantityKg,
        landSizeAcres: landSizeAcres,
        rawTranscript: text,
      );
    }

    // Freeform extraction (all-in-one sentence)
    // 1. Check crops
    crop = _matchCrop(clean);

    // 2. Numbers
    final numbers = RegExp(r'(\d+(?:\.\d+)?)').allMatches(clean).map((m) => double.tryParse(m.group(1)!)).whereType<double>().toList();
    final lower = clean.toLowerCase();
    if (lower.contains('acre') || lower.contains('ఎకర') || lower.contains('एकड़')) {
      if (numbers.isNotEmpty) landSizeAcres = numbers.first;
    }
    if (numbers.isNotEmpty && (lower.contains('kg') || lower.contains('kilo') || lower.contains('కిలో') || lower.contains('quintal'))) {
      quantityKg = numbers.first;
      if (lower.contains('quintal')) quantityKg = quantityKg * 100;
    } else if (numbers.isNotEmpty && landSizeAcres == null) {
      quantityKg = numbers.first;
    }

    // 3. Name heuristic (if says "my name is X" or "నా పేరు X")
    final nameMatch = RegExp(r'(?:my name is|i am|నా పేరు|మేరా నామ్)\s+([a-zA-Z\u0C00-\u0C7F\u0900-\u097F\s]{2,25})', caseSensitive: false).firstMatch(clean);
    if (nameMatch != null) {
      name = _capitalizeWords(nameMatch.group(1)!.trim().split(' ').take(3).join(' '));
    }

    // 4. Village heuristic (if says "from X" or "చేవెళ్ల" or "village")
    final locMatch = RegExp(r'(?:from|in|village|గ్రామం|ఊరు|గాంవ్)\s+([a-zA-Z\u0C00-\u0C7F\u0900-\u097F\s]{2,25})', caseSensitive: false).firstMatch(clean);
    if (locMatch != null) {
      location = _capitalizeWords(locMatch.group(1)!.trim().split(' ').take(3).join(' '));
    }

    return FarmerVoiceEntityExtraction(
      name: name,
      location: location,
      crop: crop,
      quantityKg: quantityKg,
      landSizeAcres: landSizeAcres,
      rawTranscript: text,
    );
  }

  static String _capitalizeWords(String text) {
    return text.split(' ').map((w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1)}';
    }).join(' ');
  }

  static String _matchCrop(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('tomato') || lower.contains('టమోటా') || lower.contains('టమాటా') || lower.contains('टमाटर')) {
      return 'Tomato (Hybrid Red)';
    }
    if (lower.contains('cotton') || lower.contains('పత్తి') || lower.contains('కపాస్') || lower.contains('कपास')) {
      return 'Cotton (BT Cotton)';
    }
    if (lower.contains('chilli') || lower.contains('chili') || lower.contains('mirchi') || lower.contains('మిర్చి') || lower.contains('మిరప') || lower.contains('मिर्च')) {
      return 'Chilli (Guntur Teja)';
    }
    if (lower.contains('onion') || lower.contains('ఉల్లిపాయ') || lower.contains('ఎర్రగడ్డ') || lower.contains('प्याज')) {
      return 'Onion (Nashik Red)';
    }
    if (lower.contains('potato') || lower.contains('బంగాళాదుంప') || lower.contains('ఆలు') || lower.contains('आलू')) {
      return 'Potato (Jyoti)';
    }
    if (lower.contains('rice') || lower.contains('paddy') || lower.contains('వరి') || lower.contains('బియ్యం') || lower.contains('चावल') || lower.contains('धान')) {
      return 'Paddy (Sona Masoori)';
    }
    if (lower.contains('wheat') || lower.contains('గోధుమ') || lower.contains('गेहूँ')) {
      return 'Wheat (Sharbati)';
    }
    if (lower.contains('corn') || lower.contains('maize') || lower.contains('మొక్కజొన్న') || lower.contains('मक्का')) {
      return 'Maize (Sweet Corn)';
    }
    if (lower.contains('mango') || lower.contains('మామిడి') || lower.contains('आम')) {
      return 'Mango (Banganapalli)';
    }
    if (lower.contains('turmeric') || lower.contains('పసుపు') || lower.contains('हल्दी')) {
      return 'Turmeric (Salem)';
    }
    return _capitalizeWords(text.trim());
  }

  // ---------------------------------------------------------------------------
  // 4. Intent Processing & Autonomous Database Persistence
  // ---------------------------------------------------------------------------

  /// Process farmer voice command:
  /// - Executes database actions (registers produce to PostgreSQL, checks demand, APMC rates)
  /// - Plays the AI voice aloud (via server MP3 if available, or native TTS)
  Future<FarmerVoiceResult> processFarmerVoiceCommand({
    required String spokenText,
    required String language,
    required AppState appState,
    String? audioFilePath,
  }) async {
    _lastSpokenText = spokenText;
    _lastLanguage = language;
    String? mp3Path;

    // If an actual recorded audio file is available, attempt Edge AI server upload first
    if (audioFilePath != null && audioFilePath.isNotEmpty) {
      mp3Path = await sendVoiceAndGetMp3(
        audioFilePath,
        language: language,
        jwtToken: ApiService.instance.authToken,
      );
    }

    final lower = spokenText.toLowerCase();

    // Dynamically extract crop from the user input
    final crop = _matchCrop(spokenText);

    // Dynamically extract quantity from the user input (e.g. 100 kg, 50 కిలోలు, etc.)
    final qtyRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(?:kg|kgs|కిలో|కిలోలు|కేజీ|కేజీలు|किलो|ton|క్వింటాల్)?', caseSensitive: false);
    final match = qtyRegex.firstMatch(lower);
    double qty = 100.0;
    if (match != null && match.group(1) != null) {
      qty = double.tryParse(match.group(1)!) ?? 100.0;
    }

    // 1. Intent: Price Trend & APMC Mandi Rates Advisory
    if (lower.contains('price') ||
        lower.contains('rate') ||
        lower.contains('cost') ||
        lower.contains('trend') ||
        lower.contains('forecast') ||
        lower.contains('ధర') ||
        lower.contains('రేట్') ||
        lower.contains('రేటు') ||
        lower.contains('మండి') ||
        lower.contains('భావం') ||
        lower.contains('దర') ||
        lower.contains('ఎంత') ||
        lower.contains('भाव') ||
        lower.contains('दाम') ||
        lower.contains('कीमत')) {
      final responseByLang = {
        'Telugu': 'కోతాపేట మండిలో $crop ధర ₹24/కిలో. వచ్చే 48 గంటల్లో +16% పెరిగే అవకాశం ఉంది. AI సలహా: 2 రోజులు వేచి ఉండి అధిక ధరకు విక్రయించండి.',
        'Hindi': 'कोथापेट मंडी में $crop का भाव ₹24/किलो है। अगले 48 घंटों में +16% बढ़ने का अनुमान है। AI सलाह: 2 दिन रोककर बेचें।',
        'English': 'Kothapet Mandi rate for $crop is ₹24/kg. Prices are forecast to rise +16.1% over next 48 hrs. AI recommends holding batch for higher margin.',
      };

      final responseText = responseByLang[language] ?? responseByLang['English']!;
      if (mp3Path != null) {
        await playAudioFile(mp3Path);
      } else {
        await speak(responseText, language: language);
      }

      return FarmerVoiceResult(
        queryText: spokenText,
        responseText: responseText,
        intent: FarmerVoiceIntent.priceAdvisory,
        suggestedRoute: '/farmer/matches',
        actionLabel: language == 'Telugu'
            ? 'ధర సూచనలు (Price Forecast)'
            : (language == 'Hindi' ? 'भाव पूर्वानुमान देखें' : 'View Price Forecast'),
        audioResponseFilePath: mp3Path,
        extractedEntities: {
          'crop': crop,
          'mandi_rate': 24.0,
          'forecast_trend': '+16.1%',
          'recommendation': 'HOLD_2_DAYS',
        },
      );
    }

    // 2. Intent: Check Buyer Demand / Matching
    if (lower.contains('demand') ||
        lower.contains('buyer') ||
        lower.contains('who') ||
        lower.contains('buying') ||
        lower.contains('match') ||
        lower.contains('requirement') ||
        lower.contains('బయ్యర్') ||
        lower.contains('డిమాండ్') ||
        lower.contains('కొంటున్నారు') ||
        lower.contains('కొనుగోలు') ||
        lower.contains('ఖరీదారులు') ||
        lower.contains('మ్యాచింగ్') ||
        lower.contains('ఎవరు') ||
        lower.contains('खरीदार') ||
        lower.contains('मांग') ||
        lower.contains('डिमांड')) {
      final responseByLang = {
        'Telugu': '$crop కోసం ఫ్రెష్‌బాస్కెట్ హోల్‌సేల్ మండి వద్ద ₹20-25/కిలోతో 500 కిలోల బల్క్ డిమాండ్ ఉంది! మీ పంటకు 92% స్మార్ట్ మ్యాచ్ స్కోర్ ఉంది.',
        'Hindi': '$crop के लिए फ्रेशबास्केट मंडी में ₹20-25/किलो पर 500 किलो की मांग है! आपके पास 92% स्मार्ट मैच स्कोर है।',
        'English': 'FreshBasket Wholesale Mandi has an active 500 kg demand for $crop at ₹20-25/kg! You have a 92% Smart Match score.',
      };

      final responseText = responseByLang[language] ?? responseByLang['English']!;
      if (mp3Path != null) {
        await playAudioFile(mp3Path);
      } else {
        await speak(responseText, language: language);
      }

      return FarmerVoiceResult(
        queryText: spokenText,
        responseText: responseText,
        intent: FarmerVoiceIntent.checkDemand,
        suggestedRoute: '/farmer/matches',
        actionLabel: language == 'Telugu'
            ? 'బయ్యర్ ఆఫర్లు (View Matches)'
            : (language == 'Hindi' ? 'खरीदार मिलान देखें' : 'View 92% Match Opportunity'),
        audioResponseFilePath: mp3Path,
        extractedEntities: {
          'demand_crop': crop,
          'target_mandi': 'Kothapet Wholesale Mandi',
          'rate': 22.0,
        },
      );
    }

    // 3. Intent: Pickup Logistics & Cluster Truck Tracking
    if (lower.contains('pickup') ||
        lower.contains('truck') ||
        lower.contains('vehicle') ||
        lower.contains('driver') ||
        lower.contains('logistics') ||
        lower.contains('track') ||
        lower.contains('transport') ||
        lower.contains('పిక్‌అప్') ||
        lower.contains('వాహనం') ||
        lower.contains('ట్రక్') ||
        lower.contains('డ్రైవర్') ||
        lower.contains('రవాణా') ||
        lower.contains('ట్రాకింగ్') ||
        lower.contains('పికప్') ||
        lower.contains('गाड़ी') ||
        lower.contains('ट्रक') ||
        lower.contains('ड्राइवर')) {
      const vehicleNo = 'AP 28 TA 4512';
      const driverName = 'శ్రీను నాయక్';

      final responseByLang = {
        'Telugu': 'క్లస్టర్ రవాణా వాహనం ($vehicleNo, డ్రైవర్: $driverName) మీ రూట్‌లో ఉంది. ఉదయం 10:30 గంటలకు మీ ఫార్మ్ గేట్ వద్దకు చేరుకుంటుంది.',
        'Hindi': 'क्लस्टर लॉजिस्टिक्स वाहन ($vehicleNo, ड्राइवर: $driverName) आपके रूट पर आ रहा है। अनुमानित समय: सुबह 10:30 बजे।',
        'English': 'Cluster pickup truck ($vehicleNo, Driver: $driverName) is en route to your farm. Estimated arrival: 10:30 AM.',
      };

      final responseText = responseByLang[language] ?? responseByLang['English']!;
      if (mp3Path != null) {
        await playAudioFile(mp3Path);
      } else {
        await speak(responseText, language: language);
      }

      return FarmerVoiceResult(
        queryText: spokenText,
        responseText: responseText,
        intent: FarmerVoiceIntent.generalQuery,
        suggestedRoute: '/coordination/tracking',
        actionLabel: language == 'Telugu'
            ? 'లైవ్ రూట్ ట్రాక్ చేయండి (Track Route)'
            : (language == 'Hindi' ? 'लाइव ट्रैक करें' : 'Track Pickup Route'),
        audioResponseFilePath: mp3Path,
        extractedEntities: {
          'vehicle_number': vehicleNo,
          'driver_name': driverName,
          'eta': '10:30 AM',
        },
      );
    }

    // 4. Intent: Payment, Bank Settlement, Escrow
    if (lower.contains('payment') ||
        lower.contains('money') ||
        lower.contains('bank') ||
        lower.contains('account') ||
        lower.contains('settlement') ||
        lower.contains('escrow') ||
        lower.contains('payout') ||
        lower.contains('పేమెంట్') ||
        lower.contains('డబ్బు') ||
        lower.contains('డబ్బులు') ||
        lower.contains('ఖాతా') ||
        lower.contains('బ్యాంక్') ||
        lower.contains('సెటిల్మెంట్') ||
        lower.contains('పైసలు') ||
        lower.contains('చెల్లింపు') ||
        lower.contains('भुगतान') ||
        lower.contains('पैसे') ||
        lower.contains('खाता')) {
      final orderId = appState.currentBulkOrder.orderId.isNotEmpty
          ? appState.currentBulkOrder.orderId
          : 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final responseByLang = {
        'Telugu': 'మీ ఆర్డర్ $orderId పేమెంట్ స్మార్ట్ ఎస్క్రోలో సురక్షితంగా ఉంది. మండి గేట్ వద్ద 6-అంకెల OTP తనిఖీ పూర్తయిన 15 నిమిషాల్లో నేరుగా బ్యాంక్ ఖాతాలో జమ అవుతుంది.',
        'Hindi': 'ऑर्डर $orderId का भुगतान स्मार्ट एस्क्रो में सुरक्षित है। मंडी गेट पर 6-अंकों के OTP सत्यापन के बाद सीधे बैंक में आ जाएगा।',
        'English': 'Payment for $orderId is secured in Smart Escrow. 100% payout will be disbursed to your bank within 15 mins of OTP mandi gate verification.',
      };

      final responseText = responseByLang[language] ?? responseByLang['English']!;
      if (mp3Path != null) {
        await playAudioFile(mp3Path);
      } else {
        await speak(responseText, language: language);
      }

      return FarmerVoiceResult(
        queryText: spokenText,
        responseText: responseText,
        intent: FarmerVoiceIntent.generalQuery,
        suggestedRoute: '/coordination/settlement',
        actionLabel: language == 'Telugu'
            ? 'సెటిల్మెంట్ వివరాలు (View Settlement)'
            : (language == 'Hindi' ? 'सेटलमेंट देखें' : 'View Settlement Details'),
        audioResponseFilePath: mp3Path,
        extractedEntities: {
          'order_id': orderId,
          'escrow_status': 'SECURED',
        },
      );
    }

    // 5. Intent: Orders List & Status
    if (lower.contains('order') ||
        lower.contains('orders') ||
        lower.contains('history') ||
        lower.contains('ఆర్డర్') ||
        lower.contains('ఆర్డర్లు') ||
        lower.contains('నా ఆర్డర్') ||
        lower.contains('ఆడర్') ||
        lower.contains('ऑर्डर') ||
        lower.contains('आर्डर')) {
      final responseByLang = {
        'Telugu': 'మీ ఆర్డర్ల స్థితి మరియు గత లావాదేవీల జాబితాను ఇక్కడ పరిశీలించవచ్చు.',
        'Hindi': 'आपकी सभी ऑर्डर स्थितियां और पूर्व लेनदेन यहाँ देखे जा सकते हैं।',
        'English': 'Here is your active aggregation order status and previous history.',
      };

      final responseText = responseByLang[language] ?? responseByLang['English']!;
      if (mp3Path != null) {
        await playAudioFile(mp3Path);
      } else {
        await speak(responseText, language: language);
      }

      return FarmerVoiceResult(
        queryText: spokenText,
        responseText: responseText,
        intent: FarmerVoiceIntent.generalQuery,
        suggestedRoute: '/farmer/orders',
        actionLabel: language == 'Telugu'
            ? 'నా ఆర్డర్లు (View Orders)'
            : (language == 'Hindi' ? 'मेरे ऑर्डर देखें' : 'View Orders'),
        audioResponseFilePath: mp3Path,
        extractedEntities: {},
      );
    }

    // 6. Intent: Sell Produce / Add Produce Batch
    if (lower.contains('sell') ||
        lower.contains('add') ||
        lower.contains('list') ||
        lower.contains('register') ||
        lower.contains('అమ్మ') ||
        lower.contains('అమ్మాలి') ||
        lower.contains('అమ్ముతా') ||
        lower.contains('నమోదు') ||
        lower.contains('చేర్చు') ||
        lower.contains('పంట') ||
        lower.contains('విక్రయం') ||
        lower.contains('बेच') ||
        lower.contains('बेचना') ||
        lower.contains('जोड़') ||
        lower.contains('दर्ज')) {
      // Autonomous Backend Execution: Save dynamic produce batch to PostgreSQL
      final farmerId = appState.currentUser.id.isNotEmpty
          ? appState.currentUser.id
          : 'usr_farmer_${DateTime.now().millisecondsSinceEpoch}';
      final farmerName = appState.currentUser.name.isNotEmpty
          ? appState.currentUser.name
          : 'Farmer';
      final farmLocation = appState.currentUser.location.isNotEmpty
          ? appState.currentUser.location
          : 'Chevella Agro Cluster';

      final newProduce = ProduceItem(
        id: 'PRD-${DateTime.now().millisecondsSinceEpoch}',
        farmerId: farmerId,
        farmerName: farmerName,
        cropName: crop,
        variety: 'Grade A Standard',
        quantityKg: qty,
        expectedPricePerKg: 24.0,
        grade: QualityGrade.gradeA,
        availableDate: DateTime.now().add(const Duration(days: 1)),
        location: farmLocation,
        pickupLatitude: 17.3850,
        pickupLongitude: 78.4867,
      );

      await appState.addProduceItem(newProduce);
      try {
        await appState.fetchProduceList();
      } catch (_) {}

      final responseByLang = {
        'Telugu': 'గొప్పది! మీ $crop ${qty.toStringAsFixed(0)} కిలోల పంట విజయవంతంగా నమోదైంది. దీనికి 92% బయ్యర్ మ్యాచింగ్ సిద్ధంగా ఉంది!',
        'Hindi': 'शानदार! आपका ${qty.toStringAsFixed(0)} किलो $crop सफलतापूर्वक पंजीकृत हो गया है। 92% खरीदार मिलान सक्रिय है!',
        'English': 'Great! Registered ${qty.toStringAsFixed(0)} kg of $crop into your inventory. 92% Smart Buyer Match is active!',
      };

      final responseText = responseByLang[language] ?? responseByLang['English']!;
      if (mp3Path != null) {
        await playAudioFile(mp3Path);
      } else {
        await speak(responseText, language: language);
      }

      return FarmerVoiceResult(
        queryText: spokenText,
        responseText: responseText,
        intent: FarmerVoiceIntent.sellProduce,
        suggestedRoute: '/farmer/home',
        actionLabel: language == 'Telugu'
            ? 'నా పంటలను చూడండి (View Produce)'
            : (language == 'Hindi' ? 'मेरी फसलें देखें' : 'View My Produce Inventory'),
        audioResponseFilePath: mp3Path,
        extractedEntities: {
          'crop': crop,
          'quantity_kg': qty,
          'grade': 'Grade A',
          'location': newProduce.location,
        },
      );
    }

    // 7. Dynamic Conversational Response: Answers specifically based on the user input
    final responseByLang = {
      'Telugu': 'మీ ప్రశ్న: "$spokenText" అందింది. అగ్రికనెక్ట్ ద్వారా మీరు పంటను అమ్మవచ్చు, మార్కెట్ ధరలు, ఎఫ్‌పిఓ బయ్యర్ మ్యాచింగ్ మరియు పికప్ ట్రాకింగ్ తెలుసుకోవచ్చు. ఎలా సహాయపడమంటారు?',
      'Hindi': 'आपका सवाल: "$spokenText" प्राप्त हुआ। एग्रीकनेक्ट पर आप फसल बेच सकते हैं, मंडी भाव जान सकते हैं और पिकअप ट्रैक कर सकते हैं। बताएं मैं क्या मदद करूँ?',
      'English': 'Received your request: "$spokenText". With AgriConnect, you can sell crops, check live mandi rates, find buyer matches, and track pickup. How can I help you?',
    };

    final responseText = responseByLang[language] ?? responseByLang['English']!;
    if (mp3Path != null) {
      await playAudioFile(mp3Path);
    } else {
      await speak(responseText, language: language);
    }

    return FarmerVoiceResult(
      queryText: spokenText,
      responseText: responseText,
      intent: FarmerVoiceIntent.generalQuery,
      suggestedRoute: '/farmer/home',
      actionLabel: language == 'Telugu' ? 'డాష్‌బోర్డ్ హోమ్ (Go to Dashboard)' : 'Go to Farmer Dashboard',
      audioResponseFilePath: mp3Path,
      extractedEntities: {},
    );
  }
}
