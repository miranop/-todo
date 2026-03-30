import {
  createContext,
  useCallback,
  useContext,
  useState,
  type ReactNode,
} from 'react';
import {
  initGoogleAuth,
  signOutGoogle,
} from '../services/googleCalendar';

interface AuthState {
  isGoogleConnected: boolean;
  isMicrosoftConnected: boolean;
  isLoading: boolean;
  error: string | null;
}

interface AuthContextValue extends AuthState {
  signInWithGoogle: () => Promise<void>;
  signOutFromGoogle: () => void;
  isSignedIn: boolean;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>({
    isGoogleConnected: false,
    isMicrosoftConnected: false,
    isLoading: false,
    error: null,
  });

  const signInWithGoogle = useCallback(async () => {
    setState((s) => ({ ...s, isLoading: true, error: null }));
    try {
      await initGoogleAuth();
      setState((s) => ({ ...s, isGoogleConnected: true, isLoading: false }));
    } catch (e) {
      setState((s) => ({
        ...s,
        isLoading: false,
        error: e instanceof Error ? e.message : 'Google sign-in failed',
      }));
    }
  }, []);

  const signOutFromGoogle = useCallback(() => {
    signOutGoogle();
    setState((s) => ({ ...s, isGoogleConnected: false }));
  }, []);

  const value: AuthContextValue = {
    ...state,
    signInWithGoogle,
    signOutFromGoogle,
    isSignedIn: state.isGoogleConnected || state.isMicrosoftConnected,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
