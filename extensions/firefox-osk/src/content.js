const keyboardLayouts = {
    en: {
        default: [
            ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
            ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
            ['SHIFT', 'z', 'x', 'c', 'v', 'b', 'n', 'm', '⌫'],
            ['123', '🌐', ',', 'SPACE', '.', 'ENTER', 'HIDE']
        ],
        shift: [
            ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
            ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
            ['SHIFT', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
            ['123', '🌐', ',', 'SPACE', '.', 'ENTER', 'HIDE']
        ],
        symbols: [
            ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
            ['-', '/', ':', ';', '(', ')', '$', '&', '@', '"'],
            ['#+=', '.', ',', '?', '!', "'", '⌫'],
            ['ABC', '🌐', ',', 'SPACE', '.', 'ENTER', 'HIDE']
        ],
        symbolsAlt: [
            ['[', ']', '{', '}', '#', '%', '^', '*', '+', '='],
            ['_', '\\', '|', '~', '<', '>', '€', '£', '¥', '•'],
            ['123', '.', ',', '?', '!', "'", '⌫'],
            ['ABC', '🌐', ',', 'SPACE', '.', 'ENTER', 'HIDE']
        ]
    },
    ru: {
        default: [
            ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ'],
            ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э'],
            ['SHIFT', 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю', '⌫'],
            ['123', '🌐', ',', 'SPACE', '.', 'ENTER', 'HIDE']
        ],
        shift: [
            ['Й', 'Ц', 'У', 'К', 'Е', 'Н', 'Г', 'Ш', 'Щ', 'З', 'Х', 'Ъ'],
            ['Ф', 'Ы', 'В', 'А', 'П', 'Р', 'О', 'Л', 'Д', 'Ж', 'Э'],
            ['SHIFT', 'Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю', '⌫'],
            ['123', '🌐', ',', 'SPACE', '.', 'ENTER', 'HIDE']
        ],
        symbols: [
            ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
            ['-', '/', ':', ';', '(', ')', '$', '&', '@', '"'],
            ['#+=', '.', ',', '?', '!', "'", '⌫'],
            ['ABC', '🌐', ',', 'SPACE', '.', 'ENTER', 'HIDE']
        ],
        symbolsAlt: [
            ['[', ']', '{', '}', '#', '%', '^', '*', '+', '='],
            ['_', '\\', '|', '~', '<', '>', '€', '£', '¥', '•'],
            ['123', '.', ',', '?', '!', "'", '⌫'],
            ['ABC', '🌐', ',', 'SPACE', '.', 'ENTER', 'HIDE']
        ]
    },
    kz: {
        default: [
            ['ә', 'і', 'ң', 'ғ', 'ү', 'ұ', 'қ', 'ө', 'һ'],
            ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ'],
            ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э'],
            ['SHIFT', 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю', '⌫'],
            ['123', '🌐', ',', 'SPACE', '.', 'ENTER', 'HIDE']
        ],
        shift: [
            ['Ә', 'І', 'Ң', 'Ғ', 'Ү', 'Ұ', 'Қ', 'Ө', 'Һ'],
            ['Й', 'Ц', 'У', 'К', 'Е', 'Н', 'Г', 'Ш', 'Щ', 'З', 'Х', 'Ъ'],
            ['Ф', 'Ы', 'В', 'А', 'П', 'Р', 'О', 'Л', 'Д', 'Ж', 'Э'],
            ['SHIFT', 'Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю', '⌫'],
            ['123', '🌐', ',', 'SPACE', '.', 'ENTER', 'HIDE']
        ],
        symbols: [
            ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
            ['-', '/', ':', ';', '(', ')', '$', '&', '@', '"'],
            ['#+=', '.', ',', '?', '!', "'", '⌫'],
            ['ABC', '🌐', ',', 'SPACE', '.', 'ENTER', 'HIDE']
        ],
        symbolsAlt: [
            ['[', ']', '{', '}', '#', '%', '^', '*', '+', '='],
            ['_', '\\', '|', '~', '<', '>', '€', '£', '¥', '•'],
            ['123', '.', ',', '?', '!', "'", '⌫'],
            ['ABC', '🌐', ',', 'SPACE', '.', 'ENTER', 'HIDE']
        ]
    }
};

class OnScreenKeyboard {
    constructor() {
        this.currentLayout = 'en';
        this.isShifted = false;
        this.isSymbols = false;
        this.isSymbolsAlt = false;
        this.isVisible = false;
        this.activeElement = null;
        this.init();
    }

    init() {
        if (document.getElementById('osk-container')) return;
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
        if (!container) return;
        container.innerHTML = '';

        const langLayout = keyboardLayouts[this.currentLayout];
        let layout;

        if (this.isSymbolsAlt) {
            layout = langLayout.symbolsAlt;
        } else if (this.isSymbols) {
            layout = langLayout.symbols;
        } else {
            layout = this.isShifted ? langLayout.shift : langLayout.default;
        }

        layout.forEach((row, rowIndex) => {
            const rowDiv = document.createElement('div');
            rowDiv.className = 'keyboard-row';

            // Special styling for Kazakh first row
            if (this.currentLayout === 'kz' && !this.isSymbols && !this.isSymbolsAlt && rowIndex === 0) {
                rowDiv.classList.add('kz-row');
            }

            row.forEach(key => {
                const keyButton = document.createElement('button');
                keyButton.className = 'key';
                keyButton.type = 'button';
                keyButton.textContent = key;

                // Add special classes for styling
                if (key === 'SPACE') keyButton.classList.add('space');
                if (key === 'SHIFT') keyButton.classList.add('shift');
                if (key === 'ENTER') keyButton.classList.add('enter');
                if (key === '⌫') keyButton.classList.add('backspace');
                if (key === '🌐') keyButton.classList.add('lang-switch');
                if (key === '123' || key === 'ABC' || key === '#+=') keyButton.classList.add('symbol-switch');
                if (key === 'HIDE') keyButton.classList.add('hide-keyboard');

                // Event handlers
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

        const element = this.activeElement;

        switch (key) {
            case 'SHIFT':
                this.isShifted = !this.isShifted;
                this.updateKeyboardLayout();
                break;

            case 'ENTER':
                if (element.tagName === 'TEXTAREA') {
                    this.insertTextAtCursor('\n');
                } else {
                    element.form?.submit();
                    this.hideKeyboard();
                }
                break;

            case '⌫':
                this.handleBackspace();
                break;

            case 'SPACE':
                this.insertTextAtCursor(' ');
                break;

            case '🌐':
                this.cycleLanguage();
                break;

            case '123':
                this.isSymbols = true;
                this.isSymbolsAlt = false;
                this.updateKeyboardLayout();
                break;

            case '#+=':
                this.isSymbolsAlt = true;
                this.isSymbols = false;
                this.updateKeyboardLayout();
                break;

            case 'ABC':
                this.isSymbols = false;
                this.isSymbolsAlt = false;
                this.updateKeyboardLayout();
                break;

            case 'HIDE':
                this.hideKeyboard();
                break;

            default:
                this.insertTextAtCursor(key);
                // Auto-disable shift after typing one character
                if (this.isShifted && !this.isSymbols && !this.isSymbolsAlt) {
                    this.isShifted = false;
                    this.updateKeyboardLayout();
                }
        }
    }

    insertTextAtCursor(text) {
        const element = this.activeElement;
        const start = element.selectionStart || 0;
        const end = element.selectionEnd || 0;
        const value = element.value || '';

        // Insert text at cursor position
        element.value = value.substring(0, start) + text + value.substring(end);

        // Move cursor after inserted text
        const newPos = start + text.length;
        element.selectionStart = element.selectionEnd = newPos;

        // Trigger input event for reactivity
        element.dispatchEvent(new Event('input', { bubbles: true }));
        element.dispatchEvent(new Event('change', { bubbles: true }));
    }

    handleBackspace() {
        const element = this.activeElement;
        const start = element.selectionStart || 0;
        const end = element.selectionEnd || 0;
        const value = element.value || '';

        if (start !== end) {
            // Delete selection
            element.value = value.substring(0, start) + value.substring(end);
            element.selectionStart = element.selectionEnd = start;
        } else if (start > 0) {
            // Delete one character before cursor
            element.value = value.substring(0, start - 1) + value.substring(start);
            element.selectionStart = element.selectionEnd = start - 1;
        }

        element.dispatchEvent(new Event('input', { bubbles: true }));
        element.dispatchEvent(new Event('change', { bubbles: true }));
    }

    cycleLanguage() {
        const langs = ['en', 'ru', 'kz'];
        const currentIndex = langs.indexOf(this.currentLayout);
        this.currentLayout = langs[(currentIndex + 1) % langs.length];
        this.updateKeyboardLayout();
    }

    showKeyboard(element) {
        this.activeElement = element;
        const container = document.getElementById('osk-container');
        if (container) {
            container.classList.add('visible');
            this.isVisible = true;
        }
    }

    hideKeyboard() {
        const container = document.getElementById('osk-container');
        if (container) {
            container.classList.remove('visible');
            this.isVisible = false;
        }
        this.activeElement = null;
    }

    addEventListeners() {
        // Show keyboard on input focus
        document.addEventListener('focusin', (e) => {
            if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
                const type = e.target.type || 'text';
                // Exclude non-text input types
                const excludedTypes = ['checkbox', 'radio', 'button', 'submit', 'reset',
                    'file', 'image', 'color', 'range', 'hidden'];
                if (!excludedTypes.includes(type)) {
                    this.showKeyboard(e.target);
                }
            }
        });

        // Hide keyboard on click outside
        document.addEventListener('click', (e) => {
            const container = document.getElementById('osk-container');
            if (!container) return;

            const isKeyboard = container.contains(e.target);
            const isInput = e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA';
            const isSelect = e.target.closest('select');

            if (!isKeyboard && !isInput && !isSelect && this.isVisible) {
                this.hideKeyboard();
            }
        });
    }
}

// Initialize keyboard
if (!window.oskInitialized) {
    window.oskInitialized = true;
    new OnScreenKeyboard();
}
