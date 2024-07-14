# <b> <h1>FlutterExpo </b> </h1>

FlutterExpo is an all-in-one development framework that integrates Flutter for mobile apps, Laravel for the backend, and Vite for the web frontend. It includes shared styles and components to ensure a consistent design system across all platforms, similar to how Expo works for React Native.

## <h4>Project Structure </h4>


```
FlutterExpo/
├── backend/  # Laravel Backend
│ ├── app/
│ │ └── ...  # Indent nested folders for readability
│ ├── routes/
│ └── README.md
├── mobile/  # Flutter Mobile App
│ ├── lib/
│ │ └── main.dart
│ └── README.md
├── web/      # Vite Web App
│ ├── src/
│ │ └── main.js
│ ├── public/
│ │ └── index.html
│ └── README.md
├── shared/  # Shared Styles and Components
│ ├── styles/
│ │ └── style.css
│ ├── components/
│ │ └── README.md
│ └── README.md
└── docs/     # Documentation
└── README.md
```



## Getting Started

### Laravel Backend

1. **Navigate to the backend directory:**
   ```sh
   cd FlareDev/backend
   composer install
   cp .env.example .env
   php artisan key:generate
## Run the backend server:
   php artisan serve



## Flutter Mobile App
cd FlareDev/mobile
flutter pub get
## Run the mobile app:
flutter run


## Vite Web App

cd FlareDev/web
npm install
npm run dev

## Run the development server:
npm run dev


# ![All of this will be a boilerplate to framework later, instead of manually setting this up]