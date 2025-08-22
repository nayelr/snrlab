# Kela User Guide

**Kela** is a voice-first, proactive macOS assistant that lives in your menu bar. It captures screen context, processes voice input, and provides intelligent suggestions based on what you're doing.

## What Kela Does

### Core Features

**🎤 Voice Input**

- Hold **Fn** (Function key) to start voice recording
- See live audio waveform while speaking
- Release **Fn** to process your speech
- Get transcribed text and intelligent responses

**👁️ Screen Awareness**

- Automatically captures text from your active window using OCR
- Tracks which app you're using and window titles
- Understands context from what's on your screen

**🧠 Intelligent Responses**

- Processes your voice input with screen context
- Provides relevant suggestions and explanations
- Speaks responses back to you with text-to-speech

**⚡ Proactive Suggestions**

- Automatically detects error messages and offers help
- Suggests meeting agendas when calendar apps are open
- Learns from your usage patterns

**💾 Memory & Learning**

- Stores interaction history locally in SQLite
- Creates embeddings for semantic search
- Recalls relevant past conversations

## Getting Started

### First Launch

1. Open **Kela.xcodeproj** in Xcode
2. Build and run the app (⌘R)
3. Grant permissions when prompted:
   - **Screen Recording**: Required for context awareness
   - **Microphone**: Required for voice input

### Menu Bar

Kela appears as a menu bar icon (looks like a circle). Click it to see:

- **Pause/Resume**: Toggle Kela's active listening
- **Settings**: Configure hotkeys, exclusions, and preferences
- **Debug Menu** (Debug builds only): Test features
- **Quit**: Exit the app

## How to Use Kela

### Basic Voice Interaction

1. **Hold Fn** (or Command if changed in settings)
2. **Speak** your question or request
3. **Release** the key when done
4. **Listen** to Kela's spoken response

**Example Interactions:**

- "What does this error mean?" (when error is visible on screen)
- "Summarize this document"
- "Help me understand this code"
- "What should I focus on in this meeting?"

### The Whisper Bubble

When you interact with Kela, a translucent glass bubble appears showing:

- **Listening**: Live waveform while recording
- **Transcript**: What Kela heard you say
- **Response**: Kela's answer to your question
- **Actions**: Buttons for follow-up actions (when available)

**Bubble Controls:**

- **OK**: Accept and close (Enter key)
- **Dismiss**: Close without action (Escape key)

### Proactive Features

Kela automatically watches for opportunities to help:

**Error Detection**

- Spots error messages, exceptions, stack traces
- Offers to explain the error and suggest fixes
- Triggered by keywords like "error:", "Exception", "failed"

**Meeting Assistance**

- Detects calendar/meeting apps near meeting times
- Suggests agenda preparation and key points
- Activates 5 minutes before the hour

**Document Analysis**

- Notices when you focus on long documents
- Offers to summarize key points and action items
- Triggered after 60+ seconds on same document

## Settings & Customization

Access settings via the menu bar icon → **Settings**

### General Tab

- **Push-to-talk hotkey**: Choose between Fn or Command key
- **Start at login**: Launch Kela automatically when you log in

### Exclusions Tab

- **Add apps** that Kela should ignore
- **Remove exclusions** by selecting and deleting
- Enter bundle identifiers (e.g., `com.apple.Terminal`)

### Appearance Tab

- **Glass intensity**: Adjust bubble transparency
- **Compact size**: Use smaller interface elements
- **Repair Permissions**: Opens System Settings if permissions are denied

### Voice Tab

- **ASR Model Path**: Set path to Whisper model file
- **TTS Voice**: Configure text-to-speech voice
- **Test Speak**: Preview the current voice settings

## Technical Details

### Screen Capture

- Uses **ScreenCaptureKit** for efficient window capture
- Captures 600×220 pixel region around your cursor
- Performs **Vision OCR** to extract text (300-600 characters max)
- Updates every 700ms when window/app changes

### Voice Processing

- **Mock Whisper**: Currently uses placeholder transcription
- **Real Whisper**: Can integrate with whisper.cpp models
- **Audio Engine**: Records via AVAudioEngine with live level monitoring

### Intelligence

- **Local LLM Stub**: Pattern-matching responses for demo
- **Pluggable Architecture**: Ready for MLX/llama.cpp integration
- **Context Bundle**: Combines voice + screen + clipboard + history

### Memory System

- **Event Log**: Stores all interactions with timestamps
- **Embeddings**: Vector search for semantic recall
- **SQLite Database**: Local storage in `~/Library/Application Support/`

## Debug Features (Development Builds)

When running from Xcode, additional debug options appear:

**Debug Menu:**

- **Fake Proactive Suggestion**: Test suggestion UI
- **Fake Error Detected**: Simulate error detection
- **Speak Test**: Test text-to-speech system

## Privacy & Security

### Data Handling

- **All data stays local** - no cloud processing
- **Screen captures** are processed immediately and discarded
- **Voice recordings** are transcribed locally (when real Whisper is used)
- **Text only** is stored in the local database

### Permissions Required

- **Screen Recording**: To see what's on your screen for context
- **Microphone**: To process your voice commands
- **Sandboxed**: App runs in macOS sandbox for security

### What Gets Stored

- Transcribed text (not audio files)
- OCR text excerpts from screen
- LLM responses and timestamps
- App names and window titles
- No personal files or full screen content

## Troubleshooting

### Common Issues

**Menu bar icon doesn't appear**

- Check Screen Recording permission in System Settings > Privacy & Security
- Try "Repair Permissions" in Settings > Appearance

**Voice input not working**

- Verify Microphone permission is granted
- Check that Fn key is being held (not tapped)
- Try switching to Command key in Settings > General

**No screen context**

- Ensure Screen Recording permission is enabled
- Check that target app isn't in Exclusions list
- OCR works best with clear, readable text

**App crashes or errors**

- Check Console.app for detailed error messages
- Ensure macOS 14.0+ and Xcode 15+
- Try clean build (⌘⇧K then ⌘B)

### Performance Tips

- **Exclude resource-heavy apps** to reduce OCR overhead
- **Use Pause** when not needed to save CPU
- **Clear old data** periodically (manual database cleanup)

### Getting Help

- Check the **README.md** for build instructions
- Review **Console logs** for technical details
- Modify **LocalLLMStub.swift** to customize responses

## Future Enhancements

The current version includes stubs and interfaces for:

- **Real Whisper Integration**: Replace mock with actual speech recognition
- **Production LLM**: Connect to MLX, llama.cpp, or cloud APIs
- **Advanced Triggers**: More sophisticated proactive detection
- **Better Memory**: Improved embedding models and retrieval
- **Custom Actions**: User-defined response behaviors

---

**Kela** transforms your Mac into an intelligent, context-aware assistant that understands what you're doing and helps proactively. Hold Fn, speak naturally, and let Kela enhance your workflow with voice-driven AI assistance.
