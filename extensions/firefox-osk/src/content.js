const keyboardLayouts = {
    en: {
        default: [
            ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
            ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
            ['CAPS', 'z', 'x', 'c', 'v', 'b', 'n', 'm', '⌫'],
            ['?123', '🌐', 'SPACE', '.', 'ENTER', '↓']
        ],
        shift: [
            ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
            ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
            ['CAPS', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
            ['?123', '🌐', 'SPACE', '.', 'ENTER', '↓']
        ],
        symbols: [
            ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
            ['@', '#', '$', '_', '&', '-', '+', '(', ')', '/'],
            ['*', '"', '\'', ':', ';', '!', '?', '⌫'],
            ['ABC', '🌐', ',', 'SPACE', '.', 'ENTER', '↓']
        ]
    },
    ru: {
        default: [
            ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ'],
            ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э'],
            ['CAPS', 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю', '⌫'],
            ['?123', '🌐', 'SPACE', '.', 'ENTER', '↓']
        ],
        shift: [
            ['Й', 'Ц', 'У', 'К', 'Е', 'Н', 'Г', 'Ш', 'Щ', 'З', 'Х', 'Ъ'],
            ['Ф', 'Ы', 'В', 'А', 'П', 'Р', 'О', 'Л', 'Д', 'Ж', 'Э'],
            ['CAPS', 'Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю', '⌫'],
            ['?123', '🌐', 'SPACE', '.', 'ENTER', '↓']
        ],
        symbols: [
            ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
            ['@', '#', '$', '_', '&', '-', '+', '(', ')', '/'],
            ['*', '"', '\'', ':', ';', '!', '?', '⌫'],
            ['ABC', '🌐', ',', 'SPACE', '.', 'ENTER', '↓']
        ]
    },
    kz: {
        default: [
            ['ә', 'і', 'ң', 'ғ', 'ү', 'ұ', 'қ', 'ө', 'һ'],
            ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ'],
            ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э'],
            ['CAPS', 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю', '⌫'],
            ['?123', '🌐', 'SPACE', '.', 'ENTER', '↓']
        ],
        shift: [
            ['Ә', 'І', 'Ң', 'Ғ', 'Ү', 'Ұ', 'Қ', 'Ө', 'Һ'],
            ['Й', 'Ц', 'У', 'К', 'Е', 'Н', 'Г', 'Ш', 'Щ', 'З', 'Х', 'Ъ'],
            ['Ф', 'Ы', 'В', 'А', 'П', 'Р', 'О', 'Л', 'Д', 'Ж', 'Э'],
            ['CAPS', 'Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю', '⌫'],
            ['?123', '🌐', 'SPACE', '.', 'ENTER', '↓']
        ],
        symbols: [
            ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
            ['@', '#', '$', '_', '&', '-', '+', '(', ')', '/'],
            ['*', '"', '\'', ':', ';', '!', '?', '⌫'],
            ['ABC', '🌐', ',', 'SPACE', '.', 'ENTER', '↓']
        ]
    }
};

class OnScreenKeyboard {
    constructor() {
        this.currentLayout = 'en'; // en, ru, kz
        this.isShifted = false;
        this.isSymbols = false;
        this.isVisible = false;
        this.activeElement = null;
        this.init();
    }

    init() {
        // Check if container acts existing?
        if (document.getElementById('osk-container')) return;
        this.createKeyboard();
        this.addEventListeners();
    }

    createKeyboard() {
        const container = document.createElement('div');
        container.className = 'keyboard-container';
        container.id = 'osk-container';
        // Prevent mouse down from stealing focus and stop propagation
        container.onmousedown = (e) => {
            e.preventDefault();
            e.stopPropagation();
        };
        document.body.appendChild(container);
        this.updateKeyboardLayout();
    }

    updateKeyboardLayout() {
        const container = document.getElementById('osk-container');
        if (!container) return;
        container.innerHTML = '';

        const langLayout = keyboardLayouts[this.currentLayout];
        let layoutRows;

        if (this.isSymbols) {
            layoutRows = langLayout.symbols;
        } else {
            layoutRows = this.isShifted ? langLayout.shift : langLayout.default;
        }

        layoutRows.forEach((row, rowIndex) => {
            const rowDiv = document.createElement('div');
            rowDiv.className = 'keyboard-row';
            if (this.currentLayout === 'kz' && !this.isSymbols && rowIndex === 0) {
                rowDiv.classList.add('kz-row');
            }

            row.forEach(key => {
                const keyButton = document.createElement('button');
                keyButton.className = 'key';

                let displayKey = key;
                // Icons/Labels
                if (key === 'SPACE') { displayKey = ' '; keyButton.classList.add('space'); }
                else if (key === 'CAPS') { displayKey = '⇪'; keyButton.classList.add('shift'); if (this.isShifted) keyButton.classList.add('active'); }
                else if (key === 'ENTER') { displayKey = '↵'; keyButton.classList.add('enter'); }
                else if (key === '⌫') { displayKey = '⌫'; keyButton.classList.add('backspace'); }
                else if (key === '🌐') { displayKey = this.currentLayout.toUpperCase(); keyButton.classList.add('lang-switch'); }
                else if (key === '?123') { displayKey = '?123'; keyButton.classList.add('symbol-switch'); }
                else if (key === 'ABC') { displayKey = 'ABC'; keyButton.classList.add('symbol-switch'); }
                else if (key === '↓') { displayKey = '▼'; keyButton.classList.add('hide-keyboard'); }
                else { keyButton.textContent = key; }

                if (displayKey !== key && !keyButton.textContent) keyButton.textContent = displayKey;

                // Handle interaction on mousedown/touchstart to prevent focus loss
                // content scripts run with a separate DOM wrapper, but events are shared.
                const handleInteraction = (e) => {
                    e.preventDefault();
                    e.stopImmediatePropagation(); // Aggressively stop other listeners
                    this.handleKeyPress(key);
                };

                keyButton.addEventListener('mousedown', handleInteraction);
                keyButton.addEventListener('touchstart', handleInteraction, { passive: false });

                // Remove old onclick
                keyButton.onclick = null;

                rowDiv.appendChild(keyButton);
            });

            container.appendChild(rowDiv);
        });
    }

    handleKeyPress(key) {
        if (!this.activeElement) return;

        // Ensure focus is still on the element (sometimes needed)
        // this.activeElement.focus(); 

        switch (key) {
            case 'CAPS':
                this.isShifted = !this.isShifted;
                this.updateKeyboardLayout();
                break;
            case 'ENTER':
                if (this.activeElement.tagName === 'TEXTAREA') {
                    this.insertText('\n');
                } else {
                    // Try to submit form or just trigger Enter event
                    this.activeElement.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter', bubbles: true }));
                    this.activeElement.dispatchEvent(new KeyboardEvent('keyup', { key: 'Enter', bubbles: true }));
                    // Often helpful to hide keyboard on Enter in inputs
                    // this.hideKeyboard();
                }
                break;
            case '⌫':
                // Handle backspace properly (remove char at cursor)
                this.simulateBackspace();
                break;
            case 'SPACE':
                this.insertText(' ');
                break;
            case '🌐':
                this.cycleLanguage();
                break;
            case '?123':
                this.isSymbols = true;
                this.updateKeyboardLayout();
                break;
            case 'ABC':
                this.isSymbols = false;
                this.updateKeyboardLayout();
                break;
            case '↓':
                this.hideKeyboard();
                break;
            default:
                this.insertText(key);
            // If we want auto-uncap after one letter:
            // if (this.isShifted) { this.isShifted = false; this.updateKeyboardLayout(); }
            // But user asked for CAPSLOCK, so we keep it until toggled off.
        }
    }

    cycleLanguage() {
        const langs = ['en', 'ru', 'kz'];
        const idx = langs.indexOf(this.currentLayout);
        this.currentLayout = langs[(idx + 1) % langs.length];
        // Reset states
        // this.isShifted = false; // Maybe keep shift state?
        // this.isSymbols = false;
        this.updateKeyboardLayout();
    }

    insertText(text) {
        const el = this.activeElement;
        const start = el.selectionStart;
        const end = el.selectionEnd;

        // Insert text at cursor
        const val = el.value;
        const before = val.substring(0, start);
        const after = val.substring(end);

        el.value = before + text + after;

        // Move cursor
        el.selectionStart = el.selectionEnd = start + text.length;

        // Trigger events
        el.dispatchEvent(new Event('input', { bubbles: true }));
        el.dispatchEvent(new Event('change', { bubbles: true }));
    }

    simulateBackspace() {
        const el = this.activeElement;
        const start = el.selectionStart;
        const end = el.selectionEnd;
        const val = el.value;

        if (start === end) {
            if (start > 0) {
                const before = val.substring(0, start - 1);
                const after = val.substring(end);
                el.value = before + after;
                el.selectionStart = el.selectionEnd = start - 1;
            }
        } else {
            // Delete selection
            const before = val.substring(0, start);
            const after = val.substring(end);
            el.value = before + after;
            el.selectionStart = el.selectionEnd = start;
        }

        el.dispatchEvent(new Event('input', { bubbles: true }));
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
        // Don't nullify activeElement immediately if we want to support external focus changes?
        // But for safety:
        this.activeElement = null;
    }

    addEventListeners() {
        document.addEventListener('focusin', (e) => {
            if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
                const type = e.target.type;
                // Ignore specific input types? (checkbox, radio, etc)
                if (['checkbox', 'radio', 'button', 'submit', 'range', 'color', 'file', 'hidden', 'image'].includes(type)) return;

                this.showKeyboard(e.target);
            }
        });

        document.addEventListener('click', (e) => {
            const container = document.getElementById('osk-container');
            if (!container) return;

            // If click is outside keyboard AND outside the input
            if (this.isVisible &&
                !container.contains(e.target) &&
                e.target !== this.activeElement) {
                this.hideKeyboard();
            }
        });
    }
}

// Initialize
if (!window.hasOSKInitialized) {
    window.hasOSKInitialized = true;
    new OnScreenKeyboard();
}
