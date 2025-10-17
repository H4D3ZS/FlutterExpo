/**
 * Flutter App Configuration interfaces
 */
export interface FlutterTheme {
    primaryColor: string;
    colorScheme: {
        primary: string;
        secondary: string;
        surface: string;
        background: string;
    };
    textTheme: {
        headlineLarge?: Record<string, any>;
        bodyLarge?: Record<string, any>;
        bodyMedium?: Record<string, any>;
    };
}
export interface AppConfig {
    title: string;
    theme?: FlutterTheme;
    darkTheme?: FlutterTheme;
    routes: string[];
    initialRoute: string;
    supportedLocales: string[];
    currentLocale: string;
}
export interface AppConfigMessage {
    type: 'APP_CONFIG';
    timestamp: string;
    data: AppConfig;
}
export interface NavigationEvent {
    type: 'NAVIGATION';
    timestamp: string;
    data: {
        from: string;
        to: string;
        method: 'push' | 'pop' | 'replace';
    };
}
//# sourceMappingURL=app-config.d.ts.map