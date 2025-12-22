import { useRef, useEffect, useCallback } from 'react';

interface UseSpeechRecognitionReturn {
  isListening: boolean;
  toggleListening: () => void;
  transcript: string;
}

// Extend window interface for webkit speech recognition
declare global {
  interface Window {
    webkitSpeechRecognition: any;
  }
}

export const useSpeechRecognition = (
  onTranscript: (text: string) => void
): UseSpeechRecognitionReturn => {
  const recognitionRef = useRef<any>(null);
  const isListeningRef = useRef(false);
  const transcriptRef = useRef('');

  useEffect(() => {
    if ('webkitSpeechRecognition' in window) {
      recognitionRef.current = new window.webkitSpeechRecognition();
      recognitionRef.current.continuous = false;
      recognitionRef.current.interimResults = false;

      recognitionRef.current.onresult = (event: any) => {
        const result = event.results[0][0].transcript;
        transcriptRef.current = result;
        onTranscript(result);
        isListeningRef.current = false;
      };

      recognitionRef.current.onerror = () => {
        isListeningRef.current = false;
      };

      recognitionRef.current.onend = () => {
        isListeningRef.current = false;
      };
    }
  }, [onTranscript]);

  const toggleListening = useCallback(() => {
    if (!recognitionRef.current) {
      alert('Speech recognition not supported in this browser');
      return;
    }

    if (isListeningRef.current) {
      recognitionRef.current.stop();
      isListeningRef.current = false;
    } else {
      recognitionRef.current.start();
      isListeningRef.current = true;
    }
  }, []);

  return {
    isListening: isListeningRef.current,
    toggleListening,
    transcript: transcriptRef.current
  };
};
