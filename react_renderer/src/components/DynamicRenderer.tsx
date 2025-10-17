import React, { useState, useEffect } from 'react';
import { ReactComponentSpec } from '../types/react-components';
import { WebSocketMessage, MessageType, ComponentSpecMessage } from '../types/websocket-messages';

interface AppConfig {
  title: string;
  theme?: any;
  darkTheme?: any;
  routes: string[];
  initialRoute: string;
  supportedLocales: string[];
  currentLocale: string;
}

interface DynamicRendererProps {
  wsUrl: string;
}

export const DynamicRenderer: React.FC<DynamicRendererProps> = ({ wsUrl }) => {
  const [componentSpec, setComponentSpec] = useState<ReactComponentSpec | null>(null);
  const [connectionStatus, setConnectionStatus] = useState<'connecting' | 'connected' | 'disconnected'>('connecting');
  const [screenInfo, setScreenInfo] = useState<{ screenId: string; route: string; language: string } | null>(null);
  const [appConfig, setAppConfig] = useState<AppConfig | null>(null);

  useEffect(() => {
    const ws = new WebSocket(wsUrl);

    ws.onopen = () => {
      console.log('Connected to FlutterExpo translator service');
      setConnectionStatus('connected');
    };

    ws.onmessage = (event) => {
      try {
        const message: WebSocketMessage = JSON.parse(event.data);
        handleMessage(message);
      } catch (error) {
        console.error('Error parsing WebSocket message:', error);
      }
    };

    ws.onclose = () => {
      console.log('Disconnected from translator service');
      setConnectionStatus('disconnected');
    };

    ws.onerror = (error) => {
      console.error('WebSocket error:', error);
      setConnectionStatus('disconnected');
    };

    return () => {
      ws.close();
    };
  }, [wsUrl]);

  const handleMessage = (message: any) => {
    switch (message.type) {
      case 'APP_CONFIG':
        console.log('Received app configuration:', message.data);
        setAppConfig(message.data);
        // Update document title and meta tags
        document.title = message.data.title;
        updateTheme(message.data.theme);
        break;
      case MessageType.COMPONENT_SPEC:
        const specMessage = message as ComponentSpecMessage;
        console.log('Received component specification:', specMessage.data);
        setComponentSpec(specMessage.data.components);
        setScreenInfo({
          screenId: specMessage.data.screenId,
          route: specMessage.data.route,
          language: specMessage.data.language
        });
        // Update app config if provided
        if (specMessage.data.appConfig) {
          setAppConfig(specMessage.data.appConfig);
        }
        break;
      case MessageType.CONNECTION_ACK:
        console.log('Connection acknowledged:', message.data);
        break;
      case MessageType.ERROR:
        console.error('Received error:', message.data);
        break;
      default:
        console.log('Unhandled message type:', message.type);
    }
  };

  const updateTheme = (theme: any) => {
    if (!theme) return;
    
    const root = document.documentElement;
    
    // Apply theme colors as CSS custom properties
    if (theme.colorScheme) {
      root.style.setProperty('--primary-color', theme.colorScheme.primary);
      root.style.setProperty('--secondary-color', theme.colorScheme.secondary);
      root.style.setProperty('--surface-color', theme.colorScheme.surface);
      root.style.setProperty('--background-color', theme.colorScheme.background);
    }
    
    // Apply primary color
    if (theme.primaryColor) {
      root.style.setProperty('--flutter-primary', theme.primaryColor);
    }
  };

  const renderComponent = (spec: ReactComponentSpec): React.ReactElement => {
    const { type, props, style, children } = spec;
    
    const elementProps = {
      ...props,
      style: style,
      key: Math.random().toString(36) // Simple key for demo
    };

    const childElements = children?.map(child => renderComponent(child)) || [];

    return React.createElement(type, elementProps, ...childElements);
  };

  return (
    <div className="flutter-expo-app">
      {/* Development status bar - only show when no app config */}
      {!appConfig && (
        <div className="dev-status-bar">
          <span className={`status ${connectionStatus}`}>
            FlutterExpo: {connectionStatus}
          </span>
          {screenInfo && (
            <div className="screen-info">
              <span>{screenInfo.route}</span>
              <span>{screenInfo.language}</span>
            </div>
          )}
        </div>
      )}
      
      {/* Render the Flutter app as a native website */}
      <div className="flutter-app-container">
        {componentSpec ? (
          renderComponent(componentSpec)
        ) : (
          <div className="flutter-loading">
            <div className="loading-content">
              <div className="flutter-logo">
                <div className="logo-animation"></div>
              </div>
              <h2>{appConfig?.title || 'FlutterExpo App'}</h2>
              <p>Loading your Flutter application...</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default DynamicRenderer;