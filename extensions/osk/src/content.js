const keyboardLayouts = {
  en: {
    default: [
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
      ['SHIFT', 'z', 'x', 'c', 'v', 'b', 'n', 'm', '⌫'],
      ['123', '🌐', ',', 'SPACE', '.', 'ENTER', '↓']
    ],
    shift: [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['SHIFT', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
      ['123', '🌐', ',', 'SPACE', '.', 'ENTER', '↓']
    ],
    symbols: [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      ['-', '=', '_', '+', '{', '}', '[', ']', '(', ')'],
      ['!', '@', '#', '$', '%', '^', '&', '*', '|', '\\'],
      ['/', '<', '>', ',', '.', '~', '`'],
      ['ABC', '🌐', ',', 'SPACE', '.', 'ENTER', '↓']
    ]
  },
  ru: {
    default: [
      ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ'],
      ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э'],
      ['SHIFT', 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю', '⌫'],
      ['123', '🌐', ',', 'SPACE', '.', 'ENTER', '↓']
    ],
    shift: [
      ['Й', 'Ц', 'У', 'К', 'Е', 'Н', 'Г', 'Ш', 'Щ', 'З', 'Х', 'Ъ'],
      ['Ф', 'Ы', 'В', 'А', 'П', 'Р', 'О', 'Л', 'Д', 'Ж', 'Э'],
      ['SHIFT', 'Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю', '⌫'],
      ['123', '🌐', ',', 'SPACE', '.', 'ENTER', '↓']
    ],
    symbols: [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      ['-', '=', '_', '+', '{', '}', '[', ']', '(', ')'],
      ['!', '@', '#', '$', '%', '^', '&', '*', '|', '\\'],
      ['/', '<', '>', ',', '.', '~', '`'],
      ['ABC', '🌐', ',', 'SPACE', '.', 'ENTER', '↓']
    ]
  }
};

class OnScreenKeyboard {
  constructor() {
    this.currentLayout = 'en';
    this.isShifted = false;
    this.isSymbols = false;
    this.isVisible = false;
    this.activeElement = null;
    this.init();
  }

  init() {
    this.createKeyboard();
    this.addEventListeners();
  }

  createKeyboard() {
    const container = document.createElement('div');
    container.className = 'keyboard-container';
    container.id = 'osk-container';
    document.body.appendChild(container);
    this.updateKeyboardLayout();
  }

  updateKeyboardLayout() {
    const container = document.getElementById('osk-container');
    container.innerHTML = '';

    const layout = this.isSymbols 
      ? keyboardLayouts[this.currentLayout].symbols
      : this.isShifted 
        ? keyboardLayouts[this.currentLayout].shift 
        : keyboardLayouts[this.currentLayout].default;

    layout.forEach(row => {
      const rowDiv = document.createElement('div');
      rowDiv.className = 'keyboard-row';
      
      row.forEach(key => {
        const keyButton = document.createElement('button');
        keyButton.className = 'key';
        keyButton.textContent = key;
        
        if (key === 'SPACE') keyButton.className += ' space';
        if (key === 'SHIFT') keyButton.className += ' shift';
        if (key === 'ENTER') keyButton.className += ' enter';
        if (key === '⌫') keyButton.className += ' backspace';
        if (key === '🌐') keyButton.className += ' lang-switch';
        if (key === '123' || key === 'ABC') keyButton.className += ' symbol-switch';
        if (key === '↓') keyButton.className += ' hide-keyboard';
        
        keyButton.addEventListener('click', (e) => {
          e.preventDefault();
          e.stopPropagation();
          this.handleKeyPress(key);
        });
        rowDiv.appendChild(keyButton);
      });
      
      container.appendChild(rowDiv);
    });
  }

  handleKeyPress(key) {
    if (!this.activeElement) return;

    switch (key) {
      case 'SHIFT':
        this.isShifted = !this.isShifted;
        this.updateKeyboardLayout();
        break;
      case 'ENTER':
        if (this.activeElement.tagName === 'TEXTAREA') {
          this.activeElement.value += '\n';
        } else {
          this.activeElement.form?.submit();
          this.hideKeyboard();
        }
        break;
      case '⌫':
        this.activeElement.value = this.activeElement.value.slice(0, -1);
        break;
      case 'SPACE':
        this.activeElement.value += ' ';
        break;
      case '🌐':
        this.currentLayout = this.currentLayout === 'en' ? 'ru' : 'en';
        this.updateKeyboardLayout();
        break;
      case '123':
      case 'ABC':
        this.isSymbols = !this.isSymbols;
        this.updateKeyboardLayout();
        break;
      case '↓':
        this.hideKeyboard();
        break;
      default:
        this.activeElement.value += key;
        if (this.isShifted && !this.isSymbols) {
          this.isShifted = false;
          this.updateKeyboardLayout();
        }
    }

    this.activeElement.dispatchEvent(new Event('input', { bubbles: true }));
  }

  showKeyboard(element) {
    this.activeElement = element;
    const container = document.getElementById('osk-container');
    container.classList.add('visible');
    this.isVisible = true;
  }

  hideKeyboard() {
    const container = document.getElementById('osk-container');
    container.classList.remove('visible');
    this.isVisible = false;
    this.activeElement = null;
  }

  addEventListeners() {
    document.addEventListener('focusin', (e) => {
      if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
        this.showKeyboard(e.target);
      }
    });

    document.addEventListener('click', (e) => {
      if (!e.target.closest('.keyboard-container') && 
          e.target.tagName !== 'INPUT' && 
          e.target.tagName !== 'TEXTAREA' &&
          !e.target.closest('select')) {
        this.hideKeyboard();
      }
    });
  }
}

// Initialize the keyboard
new OnScreenKeyboard();
