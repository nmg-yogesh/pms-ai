import { useEffect, useRef } from 'react';

export const useAutoScroll = (dependency: any) => {
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Scroll to bottom when dependency changes (e.g., messages array reference).
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'auto', block: 'end' });
  }, [dependency]);

  return messagesEndRef;
};
