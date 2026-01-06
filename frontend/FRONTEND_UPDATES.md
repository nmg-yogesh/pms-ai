# Frontend Updates - Process HQ AI

## 🎨 Design Changes

The frontend has been completely redesigned to match the "Process HQ" branding with a modern, clean interface inspired by the provided design mockups.

### Key Visual Updates

1. **Branding**
   - Updated logo to NMG Technologies logo
   - Changed app name to "PROCESS HQ"
   - Updated tagline to "Ask Process AI HQ anything"
   - Changed primary color from purple to blue (#0066FF)

2. **Header**
   - Added logo image from S3 bucket
   - New "New Chat" button with refresh icon
   - "History Chats" button to toggle chat history sidebar
   - Cleaner, more professional layout

3. **Chat Interface**
   - Larger, more spacious message bubbles
   - Better contrast and readability
   - Updated AI assistant name to "Process AI HQ"
   - Improved timestamp and metadata display

4. **Input Area**
   - Redesigned with inline buttons
   - Better placeholder text with examples
   - Voice input button integrated into input field
   - Send button with icon
   - Helper text below input

5. **Example Queries**
   - Larger, more prominent heading
   - Better example text matching the design
   - Improved category cards with icons
   - Hover effects and better spacing

## 📊 New Features

### 1. Chart Visualizations

Added automatic chart generation for query results:

- **Auto-detection**: Automatically determines the best chart type based on data
- **Chart Types**:
  - Bar Chart (default for most data)
  - Pie Chart (for categorical data with counts)
  - Line Chart (for time-series data)
  - Doughnut Chart (variant of pie chart)

- **Toggle View**: Users can switch between chart and table view
- **Smart Display**: Only shows charts for appropriate data (2-50 rows)

**Implementation**: `ChartVisualization.tsx` using Recharts library

### 2. Chat History Sidebar

Added a chat history feature:

- **Session Management**: Track multiple chat sessions
- **Grouped History**: Organized by Today, Yesterday, This Week, Older
- **Session Details**: Shows title, timestamp, and message count
- **New Chat**: Create new chat sessions
- **Session Switching**: Load previous conversations (placeholder for now)

**Implementation**: `ChatHistory.tsx` component

### 3. Enhanced Data Display

- **Chart/Table Toggle**: Switch between visual and tabular data
- **Collapsible Sections**: SQL query and raw data in expandable sections
- **Better Formatting**: Improved table styling and data presentation

## 🛠️ Technical Changes

### New Dependencies

```json
{
  "recharts": "^2.x.x",
  "chart.js": "^4.x.x",
  "react-chartjs-2": "^5.x.x"
}
```

### New Components

1. **ChartVisualization.tsx**
   - Renders different chart types based on data
   - Auto-detects best visualization
   - Responsive design

2. **ChatHistory.tsx**
   - Sidebar for chat session management
   - Grouped by time periods
   - Session switching functionality

### Updated Components

1. **Header.tsx**
   - Added logo image
   - New buttons for history and new chat
   - Updated branding

2. **MessageBubble.tsx**
   - Integrated chart visualization
   - Chart/Table toggle buttons
   - Better data display

3. **InputArea.tsx**
   - Redesigned layout
   - Inline buttons
   - Better UX

4. **ExampleQueries.tsx**
   - Updated styling
   - Better examples
   - Improved categories

5. **MessageList.tsx**
   - White background
   - Better spacing
   - Larger max-width

### Updated Types

```typescript
// ChatSession type for history
export interface ChatSession {
  id: string;
  title: string;
  timestamp: Date;
  messageCount: number;
}
```

## 🎯 Usage

### Running the Updated Frontend

```bash
cd frontend
npm install  # Install new dependencies
npm start    # Start development server
```

### Chart Visualization

Charts are automatically generated when:
- Query returns 2-50 rows of data
- Data has at least one numeric column
- Data has at least one string/categorical column

Users can toggle between chart and table view using the buttons above the visualization.

### Chat History

- Click "New Chat" button in header to open history sidebar
- View all previous chat sessions grouped by time
- Click on a session to load it (feature placeholder)
- Click "New Chat" to start a fresh conversation

## 🎨 Color Scheme

Updated from purple to blue theme:

- **Primary**: #0066FF (Blue)
- **Primary Hover**: #0052CC
- **Background**: #FFFFFF (White)
- **Secondary Background**: #F9FAFB (Light Gray)
- **Text**: #1F2937 (Dark Gray)
- **Border**: #E5E7EB (Light Gray)

## 📱 Responsive Design

All components are fully responsive:
- Mobile-friendly layout
- Adaptive sidebar
- Responsive charts
- Touch-friendly buttons

## 🚀 Future Enhancements

Potential improvements:

1. **Persistent Chat History**: Save sessions to backend/localStorage
2. **Export Charts**: Download charts as images
3. **More Chart Types**: Scatter plots, area charts, etc.
4. **Custom Chart Options**: Let users choose chart type
5. **Dark Mode**: Add theme toggle
6. **Search History**: Search through past conversations
7. **Share Sessions**: Share chat sessions with team members

## 📝 Notes

- Logo URL: `https://nmgtempbucket-us-east-1.s3.amazonaws.com/uploads/6808e5741ed19.png`
- Charts use Recharts library for better React integration
- Chat history is currently in-memory (not persisted)
- All colors updated to match Process HQ branding

