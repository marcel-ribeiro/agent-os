# Frontend State Management Standards

Comprehensive guidelines for managing state in React SaaS applications.

## State Management Levels

### 1. Local Component State (useState)

**When to use:**
- UI state specific to a single component
- Form input values
- Toggle states (open/closed, expanded/collapsed)
- Temporary data

**Example:**
```tsx
const UserForm = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  return (
    <form>
      <input
        value={formData.name}
        onChange={e => setFormData(prev => ({
          ...prev,
          name: e.target.value
        }))}
      />
    </form>
  );
};
```

### 2. Shared Component State (Context API)

**When to use:**
- State needed by multiple components in a subtree
- Theme preferences
- Authentication state
- User preferences
- UI state (sidebar open/closed)

**Example:**
```tsx
// contexts/AuthContext.tsx
interface AuthContextValue {
  user: User | null;
  isAuthenticated: boolean;
  login: (credentials: Credentials) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);

  const login = async (credentials: Credentials) => {
    const userData = await api.login(credentials);
    setUser(userData);
    localStorage.setItem('token', userData.token);
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('token');
  };

  const value = {
    user,
    isAuthenticated: !!user,
    login,
    logout
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

// Custom hook for consuming context
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};

// Usage in component
const Header = () => {
  const { user, logout } = useAuth();

  return (
    <header>
      <span>Welcome, {user?.name}</span>
      <button onClick={logout}>Logout</button>
    </header>
  );
};
```

### 3. Global Application State (Zustand)

**When to use:**
- State needed across many unrelated components
- Complex state with multiple actions
- State that needs to persist
- Shopping cart, notifications, global settings

**Example:**
```tsx
// stores/useCartStore.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
}

interface CartStore {
  items: CartItem[];
  addItem: (item: CartItem) => void;
  removeItem: (id: string) => void;
  updateQuantity: (id: string, quantity: number) => void;
  clearCart: () => void;
  total: number;
}

export const useCartStore = create<CartStore>()(
  persist(
    (set, get) => ({
      items: [],

      addItem: (item) => set(state => {
        const existing = state.items.find(i => i.id === item.id);
        if (existing) {
          return {
            items: state.items.map(i =>
              i.id === item.id
                ? { ...i, quantity: i.quantity + item.quantity }
                : i
            )
          };
        }
        return { items: [...state.items, item] };
      }),

      removeItem: (id) => set(state => ({
        items: state.items.filter(i => i.id !== id)
      })),

      updateQuantity: (id, quantity) => set(state => ({
        items: state.items.map(i =>
          i.id === id ? { ...i, quantity } : i
        )
      })),

      clearCart: () => set({ items: [] }),

      get total() {
        return get().items.reduce(
          (sum, item) => sum + (item.price * item.quantity),
          0
        );
      }
    }),
    {
      name: 'cart-storage' // localStorage key
    }
  )
);

// Usage in component
const Cart = () => {
  const { items, total, removeItem } = useCartStore();

  return (
    <div>
      <h2>Cart Total: ${total.toFixed(2)}</h2>
      {items.map(item => (
        <div key={item.id}>
          <span>{item.name} x {item.quantity}</span>
          <button onClick={() => removeItem(item.id)}>Remove</button>
        </div>
      ))}
    </div>
  );
};
```

### 4. Server State (TanStack Query)

**When to use:**
- Data from API/server
- Automatic caching and refetching
- Optimistic updates
- Background sync

**Example:**
```tsx
// services/userService.ts
export const userService = {
  getUsers: async (): Promise<User[]> => {
    const response = await fetch('/api/users');
    return response.json();
  },

  getUser: async (id: string): Promise<User> => {
    const response = await fetch(`/api/users/${id}`);
    return response.json();
  },

  createUser: async (data: CreateUserInput): Promise<User> => {
    const response = await fetch('/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return response.json();
  },

  updateUser: async (id: string, data: UpdateUserInput): Promise<User> => {
    const response = await fetch(`/api/users/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return response.json();
  },

  deleteUser: async (id: string): Promise<void> => {
    await fetch(`/api/users/${id}`, { method: 'DELETE' });
  }
};

// hooks/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export const useUsers = () => {
  return useQuery({
    queryKey: ['users'],
    queryFn: userService.getUsers,
    staleTime: 5 * 60 * 1000, // 5 minutes
    refetchOnWindowFocus: true
  });
};

export const useUser = (id: string) => {
  return useQuery({
    queryKey: ['users', id],
    queryFn: () => userService.getUser(id),
    enabled: !!id
  });
};

export const useCreateUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: userService.createUser,
    onSuccess: () => {
      // Invalidate and refetch users list
      queryClient.invalidateQueries({ queryKey: ['users'] });
    }
  });
};

export const useUpdateUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateUserInput }) =>
      userService.updateUser(id, data),
    onSuccess: (updatedUser) => {
      // Update cache immediately
      queryClient.setQueryData(['users', updatedUser.id], updatedUser);
      // Refetch list
      queryClient.invalidateQueries({ queryKey: ['users'] });
    }
  });
};

export const useDeleteUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: userService.deleteUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    }
  });
};

// Usage in component
const UserList = () => {
  const { data: users, isLoading, error } = useUsers();
  const deleteUser = useDeleteUser();

  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;

  const handleDelete = async (id: string) => {
    if (confirm('Are you sure?')) {
      await deleteUser.mutateAsync(id);
    }
  };

  return (
    <div>
      {users?.map(user => (
        <div key={user.id}>
          <span>{user.name}</span>
          <button onClick={() => handleDelete(user.id)}>Delete</button>
        </div>
      ))}
    </div>
  );
};
```

## State Management Patterns

### 1. Optimistic Updates

Show UI changes immediately before server confirms:

```tsx
export const useUpdateUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateUserInput }) =>
      userService.updateUser(id, data),

    // Optimistic update before mutation
    onMutate: async ({ id, data }) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: ['users', id] });

      // Snapshot previous value
      const previousUser = queryClient.getQueryData(['users', id]);

      // Optimistically update cache
      queryClient.setQueryData(['users', id], (old: User) => ({
        ...old,
        ...data
      }));

      return { previousUser };
    },

    // Rollback on error
    onError: (err, variables, context) => {
      queryClient.setQueryData(
        ['users', variables.id],
        context?.previousUser
      );
    },

    // Refetch after success or error
    onSettled: (data, error, variables) => {
      queryClient.invalidateQueries({ queryKey: ['users', variables.id] });
    }
  });
};
```

### 2. Pagination

```tsx
export const useUsersPaginated = (page: number, perPage: number = 20) => {
  return useQuery({
    queryKey: ['users', 'paginated', page, perPage],
    queryFn: () => userService.getUsers({ page, perPage }),
    keepPreviousData: true, // Keep showing old data while fetching new page
    staleTime: 5 * 60 * 1000
  });
};

// Component
const UserList = () => {
  const [page, setPage] = useState(1);
  const { data, isLoading, isPreviousData } = useUsersPaginated(page);

  return (
    <div>
      {isLoading && <Spinner />}
      <div style={{ opacity: isPreviousData ? 0.5 : 1 }}>
        {data?.users.map(user => <UserCard key={user.id} user={user} />)}
      </div>
      <Pagination
        currentPage={page}
        totalPages={data?.totalPages || 1}
        onPageChange={setPage}
      />
    </div>
  );
};
```

### 3. Infinite Scroll

```tsx
export const useUsersInfinite = () => {
  return useInfiniteQuery({
    queryKey: ['users', 'infinite'],
    queryFn: ({ pageParam = 1 }) =>
      userService.getUsers({ page: pageParam }),
    getNextPageParam: (lastPage) =>
      lastPage.hasMore ? lastPage.page + 1 : undefined
  });
};

// Component
const InfiniteUserList = () => {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage
  } = useUsersInfinite();

  const observerTarget = useRef(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      entries => {
        if (entries[0].isIntersecting && hasNextPage) {
          fetchNextPage();
        }
      },
      { threshold: 1 }
    );

    if (observerTarget.current) {
      observer.observe(observerTarget.current);
    }

    return () => observer.disconnect();
  }, [hasNextPage, fetchNextPage]);

  return (
    <div>
      {data?.pages.map((page, i) => (
        <div key={i}>
          {page.users.map(user => (
            <UserCard key={user.id} user={user} />
          ))}
        </div>
      ))}
      <div ref={observerTarget} />
      {isFetchingNextPage && <Spinner />}
    </div>
  );
};
```

### 4. Real-time Updates (WebSocket)

```tsx
// hooks/useRealtimeUsers.ts
export const useRealtimeUsers = () => {
  const queryClient = useQueryClient();
  const { data: users, ...query } = useUsers();

  useEffect(() => {
    const ws = new WebSocket('ws://api.example.com/users');

    ws.onmessage = (event) => {
      const message = JSON.parse(event.data);

      switch (message.type) {
        case 'USER_CREATED':
          queryClient.setQueryData(['users'], (old: User[] = []) => [
            ...old,
            message.user
          ]);
          break;

        case 'USER_UPDATED':
          queryClient.setQueryData(['users'], (old: User[] = []) =>
            old.map(u => u.id === message.user.id ? message.user : u)
          );
          break;

        case 'USER_DELETED':
          queryClient.setQueryData(['users'], (old: User[] = []) =>
            old.filter(u => u.id !== message.userId)
          );
          break;
      }
    };

    return () => ws.close();
  }, [queryClient]);

  return { users, ...query };
};
```

## Form State Management

### React Hook Form

**Recommended for complex forms:**

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

// Validation schema
const userSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100),
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  role: z.enum(['admin', 'member', 'viewer'])
});

type UserFormData = z.infer<typeof userSchema>;

export const UserForm = () => {
  const createUser = useCreateUser();

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset
  } = useForm<UserFormData>({
    resolver: zodResolver(userSchema),
    defaultValues: {
      name: '',
      email: '',
      password: '',
      role: 'member'
    }
  });

  const onSubmit = async (data: UserFormData) => {
    try {
      await createUser.mutateAsync(data);
      reset();
      toast.success('User created successfully');
    } catch (error) {
      toast.error('Failed to create user');
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <label htmlFor="name">Name</label>
        <input
          id="name"
          {...register('name')}
          className={errors.name ? 'error' : ''}
        />
        {errors.name && (
          <span className="error-message">{errors.name.message}</span>
        )}
      </div>

      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          {...register('email')}
          className={errors.email ? 'error' : ''}
        />
        {errors.email && (
          <span className="error-message">{errors.email.message}</span>
        )}
      </div>

      <div>
        <label htmlFor="password">Password</label>
        <input
          id="password"
          type="password"
          {...register('password')}
          className={errors.password ? 'error' : ''}
        />
        {errors.password && (
          <span className="error-message">{errors.password.message}</span>
        )}
      </div>

      <div>
        <label htmlFor="role">Role</label>
        <select id="role" {...register('role')}>
          <option value="member">Member</option>
          <option value="admin">Admin</option>
          <option value="viewer">Viewer</option>
        </select>
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating...' : 'Create User'}
      </button>
    </form>
  );
};
```

## State Persistence

### Local Storage

```tsx
// hooks/useLocalStorage.ts
export const useLocalStorage = <T,>(key: string, initialValue: T) => {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(error);
      return initialValue;
    }
  });

  const setValue = (value: T | ((val: T) => T)) => {
    try {
      const valueToStore = value instanceof Function
        ? value(storedValue)
        : value;

      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(error);
    }
  };

  return [storedValue, setValue] as const;
};

// Usage
const [theme, setTheme] = useLocalStorage('theme', 'light');
```

### Session Storage

```tsx
export const useSessionStorage = <T,>(key: string, initialValue: T) => {
  // Same implementation as useLocalStorage but use sessionStorage
  // sessionStorage.getItem / sessionStorage.setItem
};
```

## Decision Tree

**Which state management to use?**

```
Is it server data (from API)?
├─ Yes → Use TanStack Query
└─ No
   ├─ Is it used by single component?
   │  └─ Yes → Use useState
   └─ No
      ├─ Is it used by nearby components (parent/children)?
      │  └─ Yes → Use Context API
      └─ No
         └─ Is it global app state?
            └─ Yes → Use Zustand
```

## Best Practices

### 1. Colocate State
Keep state as close as possible to where it's used.

### 2. Avoid Prop Drilling
Use Context or global state instead of passing props through many levels.

### 3. Normalize State
Store data in normalized form (by ID) for easy updates.

```tsx
// ❌ Bad - nested structure
const [users, setUsers] = useState([
  { id: 1, name: 'Alice', posts: [...] },
  { id: 2, name: 'Bob', posts: [...] }
]);

// ✅ Good - normalized
const [users, setUsers] = useState({
  1: { id: 1, name: 'Alice', postIds: [1, 2] },
  2: { id: 2, name: 'Bob', postIds: [3, 4] }
});
const [posts, setPosts] = useState({
  1: { id: 1, title: 'Post 1', userId: 1 },
  2: { id: 2, title: 'Post 2', userId: 1 },
  3: { id: 3, title: 'Post 3', userId: 2 },
  4: { id: 4, title: 'Post 4', userId: 2 }
});
```

### 4. Immutable Updates
Always create new objects/arrays instead of mutating.

```tsx
// ❌ Bad - mutation
user.name = 'New Name';
setUser(user);

// ✅ Good - immutable
setUser({ ...user, name: 'New Name' });
```

### 5. Use Reducers for Complex State
When state logic is complex, use useReducer.

```tsx
type Action =
  | { type: 'ADD_ITEM'; item: CartItem }
  | { type: 'REMOVE_ITEM'; id: string }
  | { type: 'UPDATE_QUANTITY'; id: string; quantity: number };

const cartReducer = (state: CartItem[], action: Action): CartItem[] => {
  switch (action.type) {
    case 'ADD_ITEM':
      return [...state, action.item];
    case 'REMOVE_ITEM':
      return state.filter(item => item.id !== action.id);
    case 'UPDATE_QUANTITY':
      return state.map(item =>
        item.id === action.id
          ? { ...item, quantity: action.quantity }
          : item
      );
    default:
      return state;
  }
};

const [cart, dispatch] = useReducer(cartReducer, []);
```

## Checklist

- [ ] Server data managed with TanStack Query
- [ ] Local UI state uses useState
- [ ] Shared state uses Context API or Zustand
- [ ] Forms use React Hook Form with Zod validation
- [ ] Optimistic updates for better UX
- [ ] State is colocated near usage
- [ ] No unnecessary prop drilling
- [ ] State updates are immutable
- [ ] Loading and error states handled
- [ ] Cache invalidation strategy defined
- [ ] State persistence (if needed) implemented
- [ ] Real-time updates (if needed) connected
