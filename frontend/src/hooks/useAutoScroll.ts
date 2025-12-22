import { useEffect, useRef } from 'react';

export const useAutoScroll = (dependencies: any[]) => {
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // eslint-disable-next-line react-hooks/exhaustive-deps
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [dependencies]);

  return messagesEndRef;
};
