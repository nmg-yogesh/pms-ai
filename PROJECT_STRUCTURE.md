# AI Database Assistant - Project Structure

This project is organized into a modular, scalable architecture:

## Directory Structure

```
src/
├── components/           # Reusable React components
│   ├── ConfigPanel.tsx   # Database configuration UI
│   ├── Header.tsx        # App header
│   ├── MessageList.tsx   # Message container
│   ├── MessageBubble.tsx # Individual message bubble
│   ├── DataTable.tsx     # Data display table
│   ├── ExampleQueries.tsx # Example query suggestions
│   ├── InputArea.tsx     # Input and microphone controls
│   └── index.ts          # Component exports
├── hooks/                # Custom React hooks
│   ├── useSpeechRecognition.ts # Speech-to-text hook
│   ├── useAutoScroll.ts        # Auto-scroll messages
│   └── index.ts
├── services/             # External API and business logic
│   └── claudeService.ts  # Claude API integration
├── utils/                # Utility functions
│   ├── querySimulator.ts # Mock database queries
│   ├── speechUtils.ts    # Text-to-speech utilities
│   └── index.ts
├── types/                # TypeScript type definitions
│   └── index.ts
├── constants/            # App constants and config
│   └── index.ts
└── App.tsx              # Main app component
```

## Key Features

- **Modular Components**: Each component has a single responsibility
- **Custom Hooks**: Encapsulate reusable logic (speech recognition, auto-scroll)
- **Service Layer**: Centralized API calls for Claude integration
- **Type Safety**: Full TypeScript support with interfaces
- **Constants**: Centralized configuration and strings
- **Utils**: Pure functions for reusable logic

## Component Breakdown

### ConfigPanel
- Handles database configuration input
- Displays demo mode disclaimer

### Header
- Navigation and branding
- Config button

### MessageList
- Displays conversation history
- Shows loading state
- Renders example queries

### MessageBubble
- Individual message rendering
- SQL query expansion
- Data table display
- Text-to-speech button

### DataTable
- Formats query results in table format

### ExampleQueries
- Initial screen with helpful examples

### InputArea
- Text input field
- Microphone toggle
- Submit button

## Services

### claudeService
- `convertNaturalLanguageToSQL`: Converts natural language to SQL
- `generateExplanation`: Explains query results

## Hooks

### useSpeechRecognition
- Manages Web Speech API
- Returns transcript and listening state

### useAutoScroll
- Auto-scrolls message list to bottom on new messages

## Utils

### querySimulator
- Simulates database query execution

### speechUtils
- Text-to-speech functionality
- Browser support detection

## Getting Started

```bash
# Install dependencies
npm install

# Set environment variable
export REACT_APP_CLAUDE_API_KEY=your_api_key_here

# Run the app
npm start
```

## Environment Variables

- `REACT_APP_CLAUDE_API_KEY`: Your Anthropic Claude API key
