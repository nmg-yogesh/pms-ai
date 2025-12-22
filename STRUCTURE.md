```
src/
├── components/                 # UI Components
│   ├── ConfigPanel.tsx         # Database config form
│   ├── DataTable.tsx           # SQL results table
│   ├── ExampleQueries.tsx      # Example query suggestions
│   ├── Header.tsx              # App header/navbar
│   ├── InputArea.tsx           # Query input + mic button
│   ├── MessageBubble.tsx       # Single message bubble
│   ├── MessageList.tsx         # Message thread
│   └── index.ts                # Barrel export
├── hooks/                      # Custom React hooks
│   ├── useAutoScroll.ts        # Auto-scroll to latest message
│   ├── useSpeechRecognition.ts # Web Speech API wrapper
│   └── index.ts                # Barrel export
├── services/                   # External services
│   └── claudeService.ts        # Claude API client
├── types/                      # TypeScript interfaces
│   └── index.ts                # Type definitions
├── utils/                      # Utility functions
│   ├── querySimulator.ts       # Mock DB query execution
│   └── speechUtils.ts          # Text-to-speech helpers
├── constants/                  # App configuration
│   └── index.ts                # Constants & strings
├── App.tsx                     # Main component
└── index.tsx                   # App entry point

Configuration files:
├── package.json                # Dependencies
├── tsconfig.json               # TypeScript config
├── tailwind.config.js          # Tailwind CSS config (if using)
└── PROJECT_STRUCTURE.md        # This document
```

## Architecture Benefits

✅ **Separation of Concerns**: Each folder has a specific purpose
✅ **Scalability**: Easy to add new components, hooks, and services
✅ **Reusability**: Components and hooks can be used across the app
✅ **Testability**: Each module can be tested independently
✅ **Maintainability**: Clear organization makes code easy to find
✅ **Type Safety**: Full TypeScript support throughout
✅ **Performance**: Code splitting opportunities with lazy loading
