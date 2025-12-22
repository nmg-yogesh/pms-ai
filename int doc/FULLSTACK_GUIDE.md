# Full Stack Developer Interview Guide - Mid Level Position
## Comprehensive Q&A with Detailed Answers

---

## 1️⃣ React.js & Next.js (SSR + Performance)

### Core Concepts

#### Q1: Difference between CSR, SSR, SSG, ISR in Next.js. When would you use each?

**Answer:**

**CSR (Client-Side Rendering):**
- HTML is rendered in the browser using JavaScript
- Initial page load shows blank/loading screen
- SEO unfriendly, slower FCP (First Contentful Paint)
- **Use case:** Dashboards, admin panels, authenticated pages

**SSR (Server-Side Rendering):**
- HTML is generated on the server for each request
- Fresh data on every request
- Better SEO, faster FCP
- **Use case:** E-commerce product pages, news sites, dynamic content
```javascript
// Next.js 13+ App Router
export default async function Page() {
  const data = await fetch('https://api.example.com/data', { cache: 'no-store' })
  return <div>{data}</div>
}
```

**SSG (Static Site Generation):**
- HTML generated at build time
- Fastest performance, cached at CDN
- Data can be stale
- **Use case:** Blogs, documentation, marketing pages
```javascript
// Next.js Pages Router
export async function getStaticProps() {
  const data = await fetch('https://api.example.com/data')
  return { props: { data } }
}
```

**ISR (Incremental Static Regeneration):**
- Combines SSG + SSR benefits
- Static pages regenerate in background after specified time
- **Use case:** E-commerce listings, content that updates periodically
```javascript
export async function getStaticProps() {
  const data = await fetch('https://api.example.com/data')
  return { 
    props: { data },
    revalidate: 60 // Regenerate every 60 seconds
  }
}
```

---

#### Q2: How does Next.js SSR improve SEO and performance?

**Answer:**

**SEO Benefits:**
1. **Crawlable Content:** Search engine bots receive fully rendered HTML
2. **Meta Tags:** Dynamic meta tags are present in initial HTML
3. **Social Sharing:** Open Graph tags work correctly for social media previews

**Performance Benefits:**
1. **Faster FCP:** Users see content immediately without waiting for JS
2. **Reduced TTI:** Time to Interactive is faster as critical content is already rendered
3. **Better Core Web Vitals:**
   - LCP (Largest Contentful Paint): Improved by serving rendered HTML
   - CLS (Cumulative Layout Shift): Reduced as layout is pre-rendered
   - FID (First Input Delay): Better as less JS needs to execute initially

**Example:**
```javascript
// app/products/[id]/page.tsx
export async function generateMetadata({ params }) {
  const product = await getProduct(params.id)
  return {
    title: product.name,
    description: product.description,
    openGraph: {
      images: [product.image],
    },
  }
}

export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)
  return <ProductDetails product={product} />
}
```

---

#### Q3: What are App Router vs Pages Router differences?

**Answer:**

| Feature | Pages Router (Old) | App Router (New - Next.js 13+) |
|---------|-------------------|--------------------------------|
| **File Convention** | `pages/about.js` | `app/about/page.tsx` |
| **Routing** | File-based | Folder-based with special files |
| **Data Fetching** | `getServerSideProps`, `getStaticProps` | Server Components, `fetch` with caching |
| **Layouts** | `_app.js` for global | Nested layouts per route |
| **Loading States** | Manual implementation | `loading.tsx` file |
| **Error Handling** | `_error.js` | `error.tsx` with error boundaries |
| **Server Components** | Not supported | Default (RSC) |
| **Streaming** | Not supported | Supported with Suspense |

**App Router Example:**
```
app/
├── layout.tsx          # Root layout
├── page.tsx            # Home page
├── loading.tsx         # Loading UI
├── error.tsx           # Error UI
└── dashboard/
    ├── layout.tsx      # Dashboard layout
    ├── page.tsx        # Dashboard page
    └── settings/
        └── page.tsx    # Settings page
```

**Key Advantages of App Router:**
- Server Components by default (smaller bundle)
- Better streaming and Suspense support
- Nested layouts without re-rendering
- Built-in loading and error states

---

#### Q4: How does hydration work in Next.js?

**Answer:**

**Hydration Process:**
1. **Server sends HTML:** Fully rendered HTML is sent to browser
2. **Browser displays HTML:** User sees content immediately (non-interactive)
3. **JS downloads:** React JavaScript bundle downloads
4. **React attaches:** React "hydrates" the HTML by attaching event listeners
5. **Interactive:** Page becomes fully interactive

**Hydration Flow:**
```
Server → HTML (visible but not interactive)
  ↓
Client downloads JS
  ↓
React hydrates (attaches event handlers)
  ↓
Fully interactive page
```

**Common Hydration Issues:**

**Problem: Hydration Mismatch**
```javascript
// ❌ Wrong - causes hydration error
function Component() {
  return <div>{Date.now()}</div> // Different on server vs client
}

// ✅ Correct - use useEffect for client-only code
function Component() {
  const [time, setTime] = useState(null)
  
  useEffect(() => {
    setTime(Date.now())
  }, [])
  
  return <div>{time || 'Loading...'}</div>
}
```

**Suppressing Hydration Warning (when intentional):**
```javascript
<div suppressHydrationWarning>{Date.now()}</div>
```

---

#### Q5: How do you handle data fetching in Next.js (server components vs client components)?

**Answer:**

**Server Components (Default in App Router):**
- Fetch data directly in component
- No client-side JS overhead
- Direct database/API access
- Cannot use hooks like useState, useEffect

```javascript
// app/posts/page.tsx - Server Component
async function getPosts() {
  const res = await fetch('https://api.example.com/posts', {
    cache: 'no-store' // SSR
    // cache: 'force-cache' // SSG
    // next: { revalidate: 60 } // ISR
  })
  return res.json()
}

export default async function PostsPage() {
  const posts = await getPosts()
  return (
    <div>
      {posts.map(post => <PostCard key={post.id} post={post} />)}
    </div>
  )
}
```

**Client Components:**
- Use 'use client' directive
- Can use hooks (useState, useEffect)
- Runs in browser
- Use for interactivity

```javascript
// components/SearchBar.tsx - Client Component
'use client'

import { useState, useEffect } from 'react'

export default function SearchBar() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  
  useEffect(() => {
    if (query) {
      fetch(`/api/search?q=${query}`)
        .then(res => res.json())
        .then(setResults)
    }
  }, [query])
  
  return (
    <div>
      <input value={query} onChange={(e) => setQuery(e.target.value)} />
      {results.map(r => <div key={r.id}>{r.title}</div>)}
    </div>
  )
}
```

**Best Practice - Composition:**
```javascript
// Server Component (parent)
export default async function Page() {
  const initialData = await fetchData()
  
  return (
    <div>
      <ServerRenderedContent data={initialData} />
      <ClientInteractiveComponent /> {/* Client component */}
    </div>
  )
}
```

---

### Performance

#### Q6: How do you optimize large React apps?

**Answer:**

**1. Code Splitting & Lazy Loading:**
```javascript
// Dynamic imports
const HeavyComponent = lazy(() => import('./HeavyComponent'))

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <HeavyComponent />
    </Suspense>
  )
}

// Next.js dynamic imports
import dynamic from 'next/dynamic'

const DynamicComponent = dynamic(() => import('./Heavy'), {
  loading: () => <p>Loading...</p>,
  ssr: false // Disable SSR for this component
})
```

**2. Memoization:**
```javascript
// Prevent re-renders
const MemoizedComponent = React.memo(ExpensiveComponent)

// Memoize expensive calculations
const expensiveValue = useMemo(() => {
  return computeExpensiveValue(a, b)
}, [a, b])

// Memoize callbacks
const handleClick = useCallback(() => {
  doSomething(a, b)
}, [a, b])
```

**3. Virtualization for Long Lists:**
```javascript
import { FixedSizeList } from 'react-window'

function VirtualList({ items }) {
  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {({ index, style }) => (
        <div style={style}>{items[index]}</div>
      )}
    </FixedSizeList>
  )
}
```

**4. Image Optimization:**
```javascript
// Next.js Image component
import Image from 'next/image'

<Image
  src="/hero.jpg"
  alt="Hero"
  width={800}
  height={600}
  priority // For above-fold images
  placeholder="blur" // Blur-up effect
  quality={85}
/>
```

**5. Bundle Analysis:**
```bash
# Analyze bundle size
npm run build
npx @next/bundle-analyzer
```

**6. Reduce Re-renders:**
- Use React DevTools Profiler
- Implement proper key props
- Avoid inline functions in JSX
- Use state management wisely

---

#### Q7: What are Web Workers and when should you use them?

**Answer:**

**Web Workers** run JavaScript in background threads, preventing UI blocking.

**When to Use:**
- Heavy computations (data processing, encryption)
- Large data parsing (CSV, JSON)
- Image/video processing
- Complex calculations

**Example:**
```javascript
// worker.js
self.addEventListener('message', (e) => {
  const result = heavyComputation(e.data)
  self.postMessage(result)
})

function heavyComputation(data) {
  // CPU-intensive task
  let result = 0
  for (let i = 0; i < 1000000000; i++) {
    result += Math.sqrt(i)
  }
  return result
}

// main.js
const worker = new Worker('worker.js')

worker.postMessage({ data: largeDataset })

worker.addEventListener('message', (e) => {
  console.log('Result:', e.data)
})
```

**React Integration:**
```javascript
import { useEffect, useState } from 'react'

function useWebWorker(workerFunction) {
  const [result, setResult] = useState(null)
  const [error, setError] = useState(null)

  useEffect(() => {
    const worker = new Worker(
      URL.createObjectURL(
        new Blob([`(${workerFunction.toString()})()`])
      )
    )

    worker.onmessage = (e) => setResult(e.data)
    worker.onerror = (e) => setError(e.message)

    return () => worker.terminate()
  }, [])

  return { result, error }
}
```

---

#### Q8: How do you prevent unnecessary re-renders?

**Answer:**

**1. React.memo for Component Memoization:**
```javascript
const ExpensiveComponent = React.memo(({ data }) => {
  return <div>{data}</div>
}, (prevProps, nextProps) => {
  // Return true if props are equal (skip re-render)
  return prevProps.data.id === nextProps.data.id
})
```

**2. useMemo for Expensive Calculations:**
```javascript
function Component({ items }) {
  const sortedItems = useMemo(() => {
    return items.sort((a, b) => a.value - b.value)
  }, [items]) // Only recalculate when items change

  return <List items={sortedItems} />
}
```

**3. useCallback for Function References:**
```javascript
function Parent() {
  const [count, setCount] = useState(0)

  // ❌ New function on every render
  const handleClick = () => setCount(c => c + 1)

  // ✅ Same function reference
  const handleClick = useCallback(() => {
    setCount(c => c + 1)
  }, [])

  return <Child onClick={handleClick} />
}

const Child = React.memo(({ onClick }) => {
  return <button onClick={onClick}>Click</button>
})
```

**4. Proper State Structure:**
```javascript
// ❌ Bad - updating user re-renders entire component
const [state, setState] = useState({
  user: {},
  posts: [],
  comments: []
})

// ✅ Good - separate state
const [user, setUser] = useState({})
const [posts, setPosts] = useState([])
const [comments, setComments] = useState([])
```

**5. Key Prop Optimization:**
```javascript
// ❌ Bad - index as key causes re-renders
{items.map((item, index) => <Item key={index} {...item} />)}

// ✅ Good - stable unique key
{items.map(item => <Item key={item.id} {...item} />)}
```

---

#### Q9: Explain useMemo, useCallback, and React.memo.

**Answer:**

**useMemo - Memoize Values:**
```javascript
const expensiveValue = useMemo(() => {
  // Expensive calculation
  return items.reduce((acc, item) => acc + item.price, 0)
}, [items]) // Only recalculate when items change
```
- **Use:** Expensive calculations, derived state
- **Returns:** Memoized value
- **Re-computes:** When dependencies change

**useCallback - Memoize Functions:**
```javascript
const handleSubmit = useCallback((data) => {
  api.submit(data)
}, []) // Function reference stays same
```
- **Use:** Passing callbacks to memoized child components
- **Returns:** Memoized function
- **Re-creates:** When dependencies change

**React.memo - Memoize Components:**
```javascript
const MemoizedChild = React.memo(({ name, onClick }) => {
  return <button onClick={onClick}>{name}</button>
})
```
- **Use:** Prevent re-renders of pure components
- **Returns:** Memoized component
- **Re-renders:** Only when props change (shallow comparison)

**Complete Example:**
```javascript
function TodoList({ todos }) {
  // Memoize filtered list
  const activeTodos = useMemo(() => {
    return todos.filter(t => !t.completed)
  }, [todos])

  // Memoize callback
  const handleToggle = useCallback((id) => {
    toggleTodo(id)
  }, [])

  return (
    <div>
      {activeTodos.map(todo => (
        <TodoItem
          key={todo.id}
          todo={todo}
          onToggle={handleToggle}
        />
      ))}
    </div>
  )
}

// Memoized component
const TodoItem = React.memo(({ todo, onToggle }) => {
  return (
    <div onClick={() => onToggle(todo.id)}>
      {todo.title}
    </div>
  )
})
```

---

#### Q10: How do you handle heavy computations on frontend?

**Answer:**

**1. Web Workers (Separate Thread):**
```javascript
// computation.worker.js
self.onmessage = function(e) {
  const result = processLargeDataset(e.data)
  self.postMessage(result)
}

// Component
function DataProcessor() {
  const [result, setResult] = useState(null)

  useEffect(() => {
    const worker = new Worker('computation.worker.js')
    worker.postMessage(largeData)
    worker.onmessage = (e) => setResult(e.data)
    return () => worker.terminate()
  }, [])
}
```

**2. Debouncing/Throttling:**
```javascript
import { debounce } from 'lodash'

const debouncedSearch = useMemo(
  () => debounce((query) => {
    performExpensiveSearch(query)
  }, 300),
  []
)
```

**3. Pagination/Infinite Scroll:**
```javascript
function InfiniteList() {
  const [page, setPage] = useState(1)
  const { data, isLoading } = useQuery(['items', page], () =>
    fetchItems(page)
  )

  return (
    <InfiniteScroll
      loadMore={() => setPage(p => p + 1)}
      hasMore={data?.hasMore}
    >
      {data?.items.map(item => <Item key={item.id} {...item} />)}
    </InfiniteScroll>
  )
}
```

**4. Progressive Rendering:**
```javascript
function HeavyList({ items }) {
  const [visibleCount, setVisibleCount] = useState(50)

  useEffect(() => {
    const timer = setTimeout(() => {
      setVisibleCount(c => Math.min(c + 50, items.length))
    }, 100)
    return () => clearTimeout(timer)
  }, [visibleCount])

  return items.slice(0, visibleCount).map(item => <Item {...item} />)
}
```

**5. Server-Side Processing:**
```javascript
// Move heavy computation to API
async function processData(data) {
  const response = await fetch('/api/process', {
    method: 'POST',
    body: JSON.stringify(data)
  })
  return response.json()
}
```

---

### State Management

#### Q11: Redux vs Zustand vs Context API – when to use what?

**Answer:**

**Context API:**
- **Use:** Simple global state, theme, auth user
- **Pros:** Built-in, no dependencies, simple
- **Cons:** Performance issues with frequent updates, no middleware

```javascript
const ThemeContext = createContext()

function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light')
  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  )
}
```

**Redux (with RTK):**
- **Use:** Complex state, time-travel debugging, large teams
- **Pros:** DevTools, middleware, predictable, great ecosystem
- **Cons:** Boilerplate, learning curve

```javascript
// store.js
import { configureStore, createSlice } from '@reduxjs/toolkit'

const userSlice = createSlice({
  name: 'user',
  initialState: { data: null, loading: false },
  reducers: {
    setUser: (state, action) => {
      state.data = action.payload
    }
  }
})

export const store = configureStore({
  reducer: {
    user: userSlice.reducer
  }
})
```

**Zustand:**
- **Use:** Medium complexity, modern apps, performance-critical
- **Pros:** Minimal boilerplate, great performance, simple API
- **Cons:** Smaller ecosystem than Redux

```javascript
import create from 'zustand'

const useStore = create((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  logout: () => set({ user: null })
}))

// Usage
function Component() {
  const user = useStore(state => state.user)
  const setUser = useStore(state => state.setUser)
}
```

**Decision Matrix:**

| Scenario | Recommendation |
|----------|---------------|
| Theme, locale, simple auth | Context API |
| Small-medium app, modern stack | Zustand |
| Large app, complex state, team standards | Redux |
| Server state (API data) | TanStack Query |

---

#### Q12: How does RTK Query / TanStack Query work internally?

**Answer:**

**TanStack Query (React Query) Internals:**

**1. Query Cache:**
```javascript
// Internal cache structure
{
  'users': {
    data: [...],
    status: 'success',
    dataUpdatedAt: 1234567890,
    error: null
  },
  'user-1': {
    data: {...},
    status: 'success',
    dataUpdatedAt: 1234567891
  }
}
```

**2. How it Works:**
```javascript
import { useQuery } from '@tanstack/react-query'

function Users() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['users'], // Cache key
    queryFn: fetchUsers,  // Fetch function
    staleTime: 5000,      // Data fresh for 5s
    cacheTime: 300000,    // Cache for 5min
  })
}

// Internal flow:
// 1. Check cache for 'users' key
// 2. If cached and fresh (< staleTime), return cached data
// 3. If stale, return cached data + refetch in background
// 4. If not cached, show loading + fetch
// 5. Update cache with new data
// 6. Notify all components using this query
```

**3. Automatic Refetching:**
- Window focus refetch
- Network reconnect refetch
- Interval refetch
- Manual refetch

**RTK Query:**
```javascript
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react'

const api = createApi({
  reducerPath: 'api',
  baseQuery: fetchBaseQuery({ baseUrl: '/api' }),
  endpoints: (builder) => ({
    getUsers: builder.query({
      query: () => 'users',
      // Provides cache tags
      providesTags: ['Users']
    }),
    addUser: builder.mutation({
      query: (user) => ({
        url: 'users',
        method: 'POST',
        body: user
      }),
      // Invalidates cache tags
      invalidatesTags: ['Users']
    })
  })
})

// Auto-generated hooks
const { useGetUsersQuery, useAddUserMutation } = api
```

**Key Differences:**

| Feature | TanStack Query | RTK Query |
|---------|---------------|-----------|
| Integration | Standalone | Redux required |
| Bundle Size | Smaller | Larger (includes Redux) |
| DevTools | Separate | Redux DevTools |
| Learning Curve | Easier | Steeper |
| Flexibility | More flexible | More opinionated |

---

#### Q13: How does caching and refetching work in TanStack Query?

**Answer:**

**Cache Lifecycle:**

```javascript
const { data } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  staleTime: 5000,      // 5 seconds
  cacheTime: 300000,    // 5 minutes
  refetchOnWindowFocus: true,
  refetchOnReconnect: true,
  refetchInterval: 10000, // 10 seconds
})
```

**States:**
1. **Fresh:** Data is fresh (< staleTime), no refetch
2. **Stale:** Data is stale (> staleTime), refetch on trigger
3. **Inactive:** No components using this query
4. **Garbage Collected:** Removed from cache after cacheTime

**Timeline Example:**
```
0s:    Query executes → Data cached (fresh)
5s:    Data becomes stale
10s:   Window focus → Refetch (because stale)
15s:   Component unmounts → Query inactive
5min:  Cache garbage collected
```

**Cache Invalidation:**
```javascript
import { useQueryClient } from '@tanstack/react-query'

function AddTodo() {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: addTodo,
    onSuccess: () => {
      // Invalidate and refetch
      queryClient.invalidateQueries({ queryKey: ['todos'] })

      // Or update cache directly
      queryClient.setQueryData(['todos'], (old) => [...old, newTodo])
    }
  })
}
```

**Optimistic Updates:**
```javascript
const mutation = useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // Cancel outgoing refetches
    await queryClient.cancelQueries({ queryKey: ['todos'] })

    // Snapshot previous value
    const previousTodos = queryClient.getQueryData(['todos'])

    // Optimistically update
    queryClient.setQueryData(['todos'], (old) =>
      old.map(t => t.id === newTodo.id ? newTodo : t)
    )

    return { previousTodos }
  },
  onError: (err, newTodo, context) => {
    // Rollback on error
    queryClient.setQueryData(['todos'], context.previousTodos)
  },
  onSettled: () => {
    // Refetch after mutation
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  }
})
```

**Prefetching:**
```javascript
// Prefetch data before user navigates
const queryClient = useQueryClient()

function TodoList() {
  const prefetchTodo = (id) => {
    queryClient.prefetchQuery({
      queryKey: ['todo', id],
      queryFn: () => fetchTodo(id),
    })
  }

  return (
    <div>
      {todos.map(todo => (
        <Link
          to={`/todo/${todo.id}`}
          onMouseEnter={() => prefetchTodo(todo.id)}
        >
          {todo.title}
        </Link>
      ))}
    </div>
  )
}
```

---

## 2️⃣ JavaScript / TypeScript

#### Q14: Difference between interface and type in TypeScript?

**Answer:**

**Interface:**
```typescript
interface User {
  id: number
  name: string
}

// Can be extended
interface Admin extends User {
  role: string
}

// Can be merged (declaration merging)
interface User {
  email: string // Merged with above
}
```

**Type:**
```typescript
type User = {
  id: number
  name: string
}

// Can use unions
type Status = 'active' | 'inactive' | 'pending'

// Can use intersections
type Admin = User & {
  role: string
}

// Can use mapped types
type Readonly<T> = {
  readonly [P in keyof T]: T[P]
}
```

**Key Differences:**

| Feature | Interface | Type |
|---------|-----------|------|
| Extends | ✅ `extends` | ✅ `&` intersection |
| Declaration Merging | ✅ Yes | ❌ No |
| Union Types | ❌ No | ✅ Yes |
| Mapped Types | ❌ No | ✅ Yes |
| Primitives | ❌ No | ✅ Yes |
| Tuples | ⚠️ Limited | ✅ Full support |
| Performance | Slightly faster | Slightly slower |

**When to Use:**

**Use Interface:**
- Object shapes
- Class contracts
- Public API (allows extension)
- React component props

**Use Type:**
- Unions (`'a' | 'b'`)
- Intersections
- Mapped types
- Utility types
- Primitives

**Best Practice:**
```typescript
// ✅ Interface for object shapes
interface UserProps {
  name: string
  age: number
}

// ✅ Type for unions/complex types
type Status = 'loading' | 'success' | 'error'
type ApiResponse<T> = { data: T } | { error: string }
```

---

#### Q15: What are generics? Give real-world usage.

**Answer:**

**Generics** allow writing reusable, type-safe code that works with multiple types.

**Basic Example:**
```typescript
// Without generics - not reusable
function getFirstNumber(arr: number[]): number {
  return arr[0]
}

// With generics - reusable
function getFirst<T>(arr: T[]): T {
  return arr[0]
}

const firstNum = getFirst<number>([1, 2, 3]) // number
const firstStr = getFirst<string>(['a', 'b']) // string
const firstUser = getFirst<User>([user1, user2]) // User
```

**Real-World Examples:**

**1. API Response Wrapper:**
```typescript
interface ApiResponse<T> {
  data: T
  status: number
  message: string
}

async function fetchData<T>(url: string): Promise<ApiResponse<T>> {
  const response = await fetch(url)
  return response.json()
}

// Usage
const users = await fetchData<User[]>('/api/users')
// users.data is User[]

const post = await fetchData<Post>('/api/posts/1')
// post.data is Post
```

**2. React Component Props:**
```typescript
interface SelectProps<T> {
  options: T[]
  value: T
  onChange: (value: T) => void
  getLabel: (option: T) => string
}

function Select<T>({ options, value, onChange, getLabel }: SelectProps<T>) {
  return (
    <select value={getLabel(value)} onChange={(e) => {
      const option = options.find(o => getLabel(o) === e.target.value)
      if (option) onChange(option)
    }}>
      {options.map(option => (
        <option key={getLabel(option)} value={getLabel(option)}>
          {getLabel(option)}
        </option>
      ))}
    </select>
  )
}

// Usage
<Select<User>
  options={users}
  value={selectedUser}
  onChange={setSelectedUser}
  getLabel={(user) => user.name}
/>
```

**3. Custom Hooks:**
```typescript
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key)
    return stored ? JSON.parse(stored) : initialValue
  })

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value))
  }, [key, value])

  return [value, setValue] as const
}

// Usage
const [user, setUser] = useLocalStorage<User>('user', null)
const [theme, setTheme] = useLocalStorage<'light' | 'dark'>('theme', 'light')
```

**4. Generic Constraints:**
```typescript
interface HasId {
  id: number
}

function findById<T extends HasId>(items: T[], id: number): T | undefined {
  return items.find(item => item.id === id)
}

// Works with any type that has 'id'
const user = findById(users, 1)
const post = findById(posts, 1)
```

---

#### Q16: Explain event loop, microtasks, macrotasks.

**Answer:**

**Event Loop** is JavaScript's concurrency model that handles asynchronous operations.

**Components:**
1. **Call Stack:** Executes synchronous code
2. **Web APIs:** Browser APIs (setTimeout, fetch, DOM events)
3. **Task Queue (Macrotask):** setTimeout, setInterval, I/O
4. **Microtask Queue:** Promises, queueMicrotask, MutationObserver
5. **Event Loop:** Coordinates execution

**Execution Order:**
```
1. Execute all synchronous code (call stack)
2. Execute ALL microtasks
3. Execute ONE macrotask
4. Execute ALL microtasks again
5. Render (if needed)
6. Repeat from step 3
```

**Example:**
```javascript
console.log('1: Sync')

setTimeout(() => console.log('2: Macrotask (setTimeout)'), 0)

Promise.resolve().then(() => console.log('3: Microtask (Promise)'))

queueMicrotask(() => console.log('4: Microtask (queueMicrotask)'))

console.log('5: Sync')

// Output:
// 1: Sync
// 5: Sync
// 3: Microtask (Promise)
// 4: Microtask (queueMicrotask)
// 2: Macrotask (setTimeout)
```

**Complex Example:**
```javascript
console.log('Start')

setTimeout(() => {
  console.log('Timeout 1')
  Promise.resolve().then(() => console.log('Promise in Timeout 1'))
}, 0)

Promise.resolve()
  .then(() => {
    console.log('Promise 1')
    setTimeout(() => console.log('Timeout in Promise 1'), 0)
  })
  .then(() => console.log('Promise 2'))

setTimeout(() => console.log('Timeout 2'), 0)

console.log('End')

// Output:
// Start
// End
// Promise 1
// Promise 2
// Timeout 1
// Promise in Timeout 1
// Timeout in Promise 1
// Timeout 2
```

**Visual Flow:**
```
Call Stack: [console.log('Start')]
Microtasks: []
Macrotasks: []

↓ Execute sync code

Call Stack: []
Microtasks: [Promise 1]
Macrotasks: [Timeout 1, Timeout 2]

↓ Execute ALL microtasks

Call Stack: []
Microtasks: [Promise 2]
Macrotasks: [Timeout 1, Timeout 2, Timeout in Promise 1]

↓ Execute ALL microtasks

Call Stack: []
Microtasks: []
Macrotasks: [Timeout 1, Timeout 2, Timeout in Promise 1]

↓ Execute ONE macrotask

Call Stack: []
Microtasks: [Promise in Timeout 1]
Macrotasks: [Timeout 2, Timeout in Promise 1]

... and so on
```

---

#### Q17: How does debounce vs throttle work?

**Answer:**

**Debounce:** Delays execution until after a pause in events.
**Throttle:** Limits execution to once per time period.

**Debounce Implementation:**
```javascript
function debounce(func, delay) {
  let timeoutId

  return function(...args) {
    clearTimeout(timeoutId)

    timeoutId = setTimeout(() => {
      func.apply(this, args)
    }, delay)
  }
}

// Usage
const searchAPI = debounce((query) => {
  fetch(`/api/search?q=${query}`)
}, 300)

// User types: "h" "e" "l" "l" "o"
// Only calls API once, 300ms after last keystroke
```

**Throttle Implementation:**
```javascript
function throttle(func, limit) {
  let inThrottle

  return function(...args) {
    if (!inThrottle) {
      func.apply(this, args)
      inThrottle = true

      setTimeout(() => {
        inThrottle = false
      }, limit)
    }
  }
}

// Usage
const handleScroll = throttle(() => {
  console.log('Scroll position:', window.scrollY)
}, 1000)

window.addEventListener('scroll', handleScroll)
// Logs at most once per second while scrolling
```

**React Hooks:**
```javascript
import { useCallback, useRef } from 'react'

function useDebounce(callback, delay) {
  const timeoutRef = useRef(null)

  return useCallback((...args) => {
    clearTimeout(timeoutRef.current)
    timeoutRef.current = setTimeout(() => {
      callback(...args)
    }, delay)
  }, [callback, delay])
}

function useThrottle(callback, limit) {
  const inThrottle = useRef(false)

  return useCallback((...args) => {
    if (!inThrottle.current) {
      callback(...args)
      inThrottle.current = true
      setTimeout(() => {
        inThrottle.current = false
      }, limit)
    }
  }, [callback, limit])
}

// Usage in component
function SearchComponent() {
  const debouncedSearch = useDebounce((query) => {
    api.search(query)
  }, 300)

  return <input onChange={(e) => debouncedSearch(e.target.value)} />
}
```

**When to Use:**

| Scenario | Use |
|----------|-----|
| Search input | Debounce (wait for user to stop typing) |
| Auto-save | Debounce (save after user stops editing) |
| Scroll events | Throttle (limit frequency) |
| Window resize | Throttle (limit frequency) |
| Button clicks | Debounce (prevent double-click) |
| API rate limiting | Throttle (respect rate limits) |

---

#### Q18: Explain memory leaks in JavaScript and how to prevent them.

**Answer:**

**Common Causes:**

**1. Global Variables:**
```javascript
// ❌ Memory leak
function createLeak() {
  leakedVar = 'This is global!' // No var/let/const
}

// ✅ Fixed
function noLeak() {
  const localVar = 'This is local'
}
```

**2. Event Listeners Not Removed:**
```javascript
// ❌ Memory leak
function Component() {
  useEffect(() => {
    window.addEventListener('scroll', handleScroll)
    // Missing cleanup!
  }, [])
}

// ✅ Fixed
function Component() {
  useEffect(() => {
    window.addEventListener('scroll', handleScroll)
    return () => {
      window.removeEventListener('scroll', handleScroll)
    }
  }, [])
}
```

**3. Timers Not Cleared:**
```javascript
// ❌ Memory leak
function Component() {
  useEffect(() => {
    setInterval(() => {
      console.log('Running...')
    }, 1000)
    // Missing cleanup!
  }, [])
}

// ✅ Fixed
function Component() {
  useEffect(() => {
    const intervalId = setInterval(() => {
      console.log('Running...')
    }, 1000)

    return () => clearInterval(intervalId)
  }, [])
}
```

**4. Closures Holding References:**
```javascript
// ❌ Memory leak
function createClosure() {
  const largeData = new Array(1000000).fill('data')

  return function() {
    // This closure keeps largeData in memory
    console.log(largeData[0])
  }
}

// ✅ Fixed
function createClosure() {
  const largeData = new Array(1000000).fill('data')
  const firstItem = largeData[0] // Extract only what's needed

  return function() {
    console.log(firstItem)
  }
  // largeData can be garbage collected
}
```

**5. Detached DOM Nodes:**
```javascript
// ❌ Memory leak
let detachedDiv = document.createElement('div')
document.body.appendChild(detachedDiv)
document.body.removeChild(detachedDiv)
// detachedDiv still in memory!

// ✅ Fixed
let detachedDiv = document.createElement('div')
document.body.appendChild(detachedDiv)
document.body.removeChild(detachedDiv)
detachedDiv = null // Allow garbage collection
```

**Detection Tools:**

**1. Chrome DevTools Memory Profiler:**
```javascript
// Take heap snapshot before
// Perform action
// Take heap snapshot after
// Compare snapshots to find leaks
```

**2. Performance Monitor:**
```javascript
// Monitor:
// - JS Heap Size (should not continuously grow)
// - DOM Nodes (should not continuously grow)
// - Event Listeners (should not continuously grow)
```

**3. Code Example - Detecting Leaks:**
```javascript
// Leak detector utility
class LeakDetector {
  constructor() {
    this.refs = new WeakMap()
  }

  track(obj, name) {
    this.refs.set(obj, name)
  }

  check() {
    // Force garbage collection (Chrome with --expose-gc flag)
    if (global.gc) {
      global.gc()
    }

    console.log('Tracked objects:', this.refs)
  }
}

const detector = new LeakDetector()
detector.track(myComponent, 'MyComponent')
```

**Prevention Checklist:**
- ✅ Always cleanup event listeners
- ✅ Clear timers (setTimeout, setInterval)
- ✅ Cancel pending requests on unmount
- ✅ Nullify references to large objects
- ✅ Use WeakMap/WeakSet for caches
- ✅ Avoid global variables
- ✅ Profile memory regularly

---

## 3️⃣ Python & FastAPI

#### Q19: Why FastAPI over Flask or Django?

**Answer:**

**FastAPI Advantages:**

**1. Performance:**
- Built on Starlette (async) and Pydantic
- One of the fastest Python frameworks
- Comparable to Node.js and Go

**Benchmark:**
```
FastAPI:  ~20,000 requests/sec
Flask:    ~3,000 requests/sec
Django:   ~2,000 requests/sec
```

**2. Automatic API Documentation:**
```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/users/{user_id}")
async def get_user(user_id: int, q: str = None):
    """Get user by ID with optional query"""
    return {"user_id": user_id, "q": q}

# Automatic Swagger UI at /docs
# Automatic ReDoc at /redoc
```

**3. Type Safety with Pydantic:**
```python
from pydantic import BaseModel, EmailStr, validator

class User(BaseModel):
    name: str
    email: EmailStr
    age: int

    @validator('age')
    def validate_age(cls, v):
        if v < 18:
            raise ValueError('Must be 18+')
        return v

@app.post("/users")
async def create_user(user: User):
    # Automatic validation!
    # Automatic JSON serialization!
    return user
```

**4. Async Support:**
```python
# FastAPI - Native async
@app.get("/data")
async def get_data():
    data = await fetch_from_db()
    return data

# Flask - No native async (until 2.0)
@app.route("/data")
def get_data():
    data = fetch_from_db()  # Blocking
    return data
```

**Comparison Table:**

| Feature | FastAPI | Flask | Django |
|---------|---------|-------|--------|
| Performance | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Async Support | ✅ Native | ⚠️ Limited | ⚠️ Limited |
| Auto Docs | ✅ Built-in | ❌ Manual | ❌ Manual |
| Type Safety | ✅ Pydantic | ❌ No | ❌ No |
| Learning Curve | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| Ecosystem | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| ORM | ❌ BYO | ❌ BYO | ✅ Built-in |
| Admin Panel | ❌ No | ❌ No | ✅ Built-in |

**When to Use:**

**FastAPI:**
- Modern APIs
- Microservices
- High performance needed
- Type safety important
- Async operations

**Flask:**
- Simple apps
- Prototypes
- Need flexibility
- Large ecosystem needed

**Django:**
- Full-stack apps
- Admin panel needed
- Batteries-included approach
- Traditional web apps

---


