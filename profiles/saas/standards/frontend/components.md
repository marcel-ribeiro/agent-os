# Frontend Component Standards

Comprehensive guidelines for building React components in SaaS applications.

## Component Architecture

### Component Types

**1. Layout Components**
- Purpose: Define page structure
- Examples: `Header`, `Sidebar`, `MainLayout`, `DashboardLayout`
- Characteristics: No business logic, purely structural

**2. UI Components (Presentational)**
- Purpose: Reusable UI elements
- Examples: `Button`, `Input`, `Card`, `Modal`, `Table`
- Characteristics: Receive data via props, emit events, no API calls

**3. Feature Components (Container)**
- Purpose: Business logic and data fetching
- Examples: `UserList`, `ProductDashboard`, `OrderForm`
- Characteristics: Manage state, fetch data, orchestrate UI components

**4. Page Components**
- Purpose: Route-level components
- Examples: `HomePage`, `DashboardPage`, `SettingsPage`
- Characteristics: Top-level components that combine layouts and features

## File Structure

### Recommended Structure

```
src/
├── components/
│   ├── ui/              # Reusable UI components
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.test.tsx
│   │   │   └── index.ts
│   │   ├── Input/
│   │   └── Card/
│   ├── layouts/         # Layout components
│   │   ├── DashboardLayout/
│   │   └── AuthLayout/
│   └── features/        # Feature-specific components
│       ├── users/
│       │   ├── UserList/
│       │   ├── UserForm/
│       │   └── UserCard/
│       └── products/
├── pages/               # Page components
│   ├── DashboardPage/
│   ├── UsersPage/
│   └── SettingsPage/
├── hooks/               # Custom hooks
├── services/            # API services
├── utils/               # Utility functions
└── types/               # TypeScript types
```

## Component Guidelines

### 1. Naming Conventions

**Components:**
- Use PascalCase: `UserCard`, `DashboardLayout`
- Be descriptive: `ConfirmDeleteModal` not just `Modal`

**Files:**
- Component file: `UserCard.tsx`
- Test file: `UserCard.test.tsx`
- Styles (if separate): `UserCard.module.css`
- Barrel export: `index.ts`

**Props:**
- Use camelCase: `isLoading`, `onSubmit`, `userId`
- Prefix booleans: `isLoading`, `hasError`, `canEdit`
- Prefix handlers: `onSubmit`, `onClick`, `onUserDelete`

### 2. Component Structure

**Standard component template:**

```tsx
import { FC } from 'react';

// Types at top
interface UserCardProps {
  user: User;
  onEdit?: (userId: string) => void;
  onDelete?: (userId: string) => void;
  isLoading?: boolean;
}

// Component definition
export const UserCard: FC<UserCardProps> = ({
  user,
  onEdit,
  onDelete,
  isLoading = false
}) => {
  // Hooks first
  const [isExpanded, setIsExpanded] = useState(false);

  // Event handlers
  const handleEdit = () => {
    onEdit?.(user.id);
  };

  const handleDelete = () => {
    onDelete?.(user.id);
  };

  // Early returns for loading/error states
  if (isLoading) {
    return <Skeleton />;
  }

  // Render
  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      <div className="actions">
        <Button onClick={handleEdit}>Edit</Button>
        <Button onClick={handleDelete} variant="destructive">
          Delete
        </Button>
      </div>
    </div>
  );
};
```

### 3. Props Best Practices

**Use TypeScript interfaces:**
```tsx
interface ButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'destructive';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  disabled?: boolean;
  onClick?: () => void;
  type?: 'button' | 'submit' | 'reset';
  className?: string;
}
```

**Provide defaults:**
```tsx
export const Button: FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  type = 'button',
  isLoading = false,
  disabled = false,
  className = '',
  children,
  onClick
}) => {
  // ...
};
```

**Use optional chaining for callbacks:**
```tsx
const handleClick = () => {
  onClick?.(); // Safe even if onClick is undefined
};
```

### 4. State Management

**Local state with useState:**
```tsx
const [isOpen, setIsOpen] = useState(false);
const [formData, setFormData] = useState({ name: '', email: '' });
```

**Derived state (don't store what can be computed):**
```tsx
// ❌ Bad - storing derived state
const [filteredUsers, setFilteredUsers] = useState([]);

// ✅ Good - compute derived state
const filteredUsers = users.filter(user =>
  user.name.toLowerCase().includes(searchTerm.toLowerCase())
);
```

**Side effects with useEffect:**
```tsx
useEffect(() => {
  // Fetch data on mount
  fetchUsers();

  // Cleanup function
  return () => {
    // Cancel requests, clear timers, etc.
  };
}, []); // Empty dependency array = run once on mount
```

**Memoization with useMemo and useCallback:**
```tsx
// Expensive computation
const sortedUsers = useMemo(() => {
  return users.sort((a, b) => a.name.localeCompare(b.name));
}, [users]);

// Stable callback reference
const handleDelete = useCallback((userId: string) => {
  deleteUser(userId);
}, [deleteUser]);
```

### 5. Custom Hooks

**Extract reusable logic into custom hooks:**

```tsx
// hooks/useUsers.ts
export const useUsers = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const fetchUsers = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await api.getUsers();
      setUsers(data);
    } catch (err) {
      setError(err as Error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  return { users, isLoading, error, refetch: fetchUsers };
};

// Usage in component
const UserList = () => {
  const { users, isLoading, error } = useUsers();

  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;

  return (
    <div>
      {users.map(user => (
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  );
};
```

**Common custom hooks patterns:**

```tsx
// Form handling
export const useForm = <T,>(initialValues: T) => {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleChange = (field: keyof T, value: any) => {
    setValues(prev => ({ ...prev, [field]: value }));
  };

  const validate = () => {
    // Validation logic
    return Object.keys(errors).length === 0;
  };

  const reset = () => {
    setValues(initialValues);
    setErrors({});
  };

  return { values, errors, handleChange, validate, reset };
};

// API query with React Query
import { useQuery } from '@tanstack/react-query';

export const useUser = (userId: string) => {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => api.getUser(userId),
    enabled: !!userId
  });
};

// Debounced value
export const useDebounce = <T,>(value: T, delay: number = 500) => {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
};
```

## Component Patterns

### 1. Compound Components

Allow flexible composition:

```tsx
interface TabsContextValue {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

const TabsContext = createContext<TabsContextValue | undefined>(undefined);

export const Tabs = ({ children, defaultTab }: TabsProps) => {
  const [activeTab, setActiveTab] = useState(defaultTab);

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
};

export const TabList = ({ children }: { children: React.ReactNode }) => {
  return <div className="tab-list">{children}</div>;
};

export const Tab = ({ value, children }: TabProps) => {
  const context = useContext(TabsContext);
  if (!context) throw new Error('Tab must be used within Tabs');

  const isActive = context.activeTab === value;

  return (
    <button
      className={`tab ${isActive ? 'active' : ''}`}
      onClick={() => context.setActiveTab(value)}
    >
      {children}
    </button>
  );
};

export const TabPanel = ({ value, children }: TabPanelProps) => {
  const context = useContext(TabsContext);
  if (!context) throw new Error('TabPanel must be used within Tabs');

  if (context.activeTab !== value) return null;

  return <div className="tab-panel">{children}</div>;
};

// Usage
<Tabs defaultTab="profile">
  <TabList>
    <Tab value="profile">Profile</Tab>
    <Tab value="settings">Settings</Tab>
  </TabList>
  <TabPanel value="profile">
    <UserProfile />
  </TabPanel>
  <TabPanel value="settings">
    <Settings />
  </TabPanel>
</Tabs>
```

### 2. Render Props

Share logic between components:

```tsx
interface DataFetcherProps<T> {
  url: string;
  children: (data: T | null, isLoading: boolean, error: Error | null) => React.ReactNode;
}

export const DataFetcher = <T,>({ url, children }: DataFetcherProps<T>) => {
  const [data, setData] = useState<T | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(setData)
      .catch(setError)
      .finally(() => setIsLoading(false));
  }, [url]);

  return <>{children(data, isLoading, error)}</>;
};

// Usage
<DataFetcher<User[]> url="/api/users">
  {(users, isLoading, error) => {
    if (isLoading) return <Spinner />;
    if (error) return <ErrorMessage error={error} />;
    return <UserList users={users} />;
  }}
</DataFetcher>
```

### 3. Higher-Order Components (HOC)

Wrap components to add functionality:

```tsx
export const withAuth = <P extends object>(
  Component: ComponentType<P>
) => {
  return (props: P) => {
    const { user, isLoading } = useAuth();

    if (isLoading) return <Spinner />;
    if (!user) return <Navigate to="/login" />;

    return <Component {...props} />;
  };
};

// Usage
const ProtectedPage = withAuth(DashboardPage);
```

## Styling

### Using Tailwind CSS

```tsx
export const Button: FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  children,
  ...props
}) => {
  const baseClasses = 'font-semibold rounded-lg transition duration-150';

  const variantClasses = {
    primary: 'bg-blue-600 hover:bg-blue-700 text-white',
    secondary: 'bg-gray-200 hover:bg-gray-300 text-gray-900',
    destructive: 'bg-red-600 hover:bg-red-700 text-white'
  };

  const sizeClasses = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg'
  };

  const className = `
    ${baseClasses}
    ${variantClasses[variant]}
    ${sizeClasses[size]}
  `.trim();

  return (
    <button className={className} {...props}>
      {children}
    </button>
  );
};
```

### Using CSS Modules

```tsx
// Button.module.css
.button {
  font-weight: 600;
  border-radius: 0.5rem;
  transition: all 150ms;
}

.primary {
  background-color: #2563eb;
  color: white;
}

.primary:hover {
  background-color: #1d4ed8;
}

// Button.tsx
import styles from './Button.module.css';

export const Button: FC<ButtonProps> = ({ variant = 'primary', children }) => {
  return (
    <button className={`${styles.button} ${styles[variant]}`}>
      {children}
    </button>
  );
};
```

## Accessibility

### Semantic HTML

```tsx
// ✅ Good - semantic HTML
<button onClick={handleClick}>Click me</button>
<nav>...</nav>
<main>...</main>

// ❌ Bad - div soup
<div onClick={handleClick}>Click me</div>
```

### ARIA Attributes

```tsx
export const Modal: FC<ModalProps> = ({ isOpen, title, children, onClose }) => {
  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
      className={isOpen ? 'block' : 'hidden'}
    >
      <div className="modal-content">
        <h2 id="modal-title">{title}</h2>
        <button
          onClick={onClose}
          aria-label="Close modal"
        >
          ×
        </button>
        {children}
      </div>
    </div>
  );
};
```

### Keyboard Navigation

```tsx
export const Dropdown: FC<DropdownProps> = ({ items, onSelect }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [focusedIndex, setFocusedIndex] = useState(0);

  const handleKeyDown = (e: KeyboardEvent) => {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        setFocusedIndex(prev => Math.min(prev + 1, items.length - 1));
        break;
      case 'ArrowUp':
        e.preventDefault();
        setFocusedIndex(prev => Math.max(prev - 1, 0));
        break;
      case 'Enter':
        e.preventDefault();
        onSelect(items[focusedIndex]);
        setIsOpen(false);
        break;
      case 'Escape':
        setIsOpen(false);
        break;
    }
  };

  return (
    <div onKeyDown={handleKeyDown}>
      {/* Dropdown UI */}
    </div>
  );
};
```

## Testing

### Component Tests with Vitest + React Testing Library

```tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { Button } from './Button';

describe('Button', () => {
  it('renders children correctly', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);

    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledOnce();
  });

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click me</Button>);
    expect(screen.getByText('Click me')).toBeDisabled();
  });

  it('shows loading spinner when isLoading', () => {
    render(<Button isLoading>Click me</Button>);
    expect(screen.getByRole('status')).toBeInTheDocument();
  });
});
```

## Performance Optimization

### Code Splitting

```tsx
import { lazy, Suspense } from 'react';

// Lazy load heavy components
const HeavyChart = lazy(() => import('./HeavyChart'));

export const Dashboard = () => {
  return (
    <div>
      <Suspense fallback={<Spinner />}>
        <HeavyChart />
      </Suspense>
    </div>
  );
};
```

### Virtualization for Long Lists

```tsx
import { useVirtualizer } from '@tanstack/react-virtual';

export const UserList = ({ users }: { users: User[] }) => {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: users.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 60
  });

  return (
    <div ref={parentRef} style={{ height: '400px', overflow: 'auto' }}>
      <div style={{ height: `${virtualizer.getTotalSize()}px` }}>
        {virtualizer.getVirtualItems().map(virtualRow => (
          <div
            key={virtualRow.key}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: `${virtualRow.size}px`,
              transform: `translateY(${virtualRow.start}px)`
            }}
          >
            <UserCard user={users[virtualRow.index]} />
          </div>
        ))}
      </div>
    </div>
  );
};
```

## Best Practices Checklist

- [ ] Component names are descriptive and PascalCase
- [ ] Props have TypeScript interfaces
- [ ] Default props are provided where appropriate
- [ ] Event handlers are prefixed with "handle" or "on"
- [ ] Loading and error states are handled
- [ ] Components are tested
- [ ] Accessibility attributes (ARIA) are included
- [ ] Keyboard navigation works
- [ ] Components are responsive
- [ ] Large components are code-split
- [ ] Long lists use virtualization
- [ ] Expensive computations are memoized
- [ ] Custom hooks extract reusable logic
- [ ] No prop drilling (use Context or state management)
- [ ] Semantic HTML is used
- [ ] Components follow single responsibility principle
