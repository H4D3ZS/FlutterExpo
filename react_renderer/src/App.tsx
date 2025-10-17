import './App.css';
import DynamicRenderer from './components/DynamicRenderer';

function App() {
  const wsUrl = 'ws://localhost:3001';

  return (
    <div className="App">
      <DynamicRenderer wsUrl={wsUrl} />
    </div>
  );
}

export default App;