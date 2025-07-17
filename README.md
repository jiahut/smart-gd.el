# smart-gd.el

> VSCode-style smart goto definition for Emacs

Bring VSCode Vim plugin's intelligent "Go to Definition" behavior to Emacs!

## 🚀 Quick Start

```elisp
(use-package smart-gd
  :after evil
  :config
  (smart-gd-setup))
```

## 🎯 How It Works

**The Magic**: When you press `gd` (or any command that calls `xref-find-definitions`):

- **At a definition** → Show references
- **At a reference** → Go to definition

This mirrors VSCode's intelligent behavior where `gd` "reads your mind" and does what you actually want!

## 🌟 Features

- **🧠 Context-aware**: Automatically switches between definitions and references
- **⚡ Zero setup**: Works with existing LSP/eglot configurations  
- **🌍 Universal**: Uses LSP for accurate detection + heuristics as fallback
- **🔧 Non-intrusive**: Uses advice system to enhance `xref-find-definitions`
- **🐛 Debug mode**: Set `smart-gd-debug` to `t` for troubleshooting

## 📖 Usage

After setup, just use `gd` as usual:

```go
// At function definition, gd shows references
func ProcessRequest(req *TranslationRequest) error {
    // At struct field definition, gd shows references  
    req.UserID = "123"
    // At method call, gd goes to definition
    return req.Validate()
}
```

## ⚙️ Configuration

### Enable Debug Mode

```elisp
(setq smart-gd-debug t)  ; Enable debug messages
```

### Manual Commands

```elisp
(smart-gd-setup)    ; Enable smart behavior
(smart-gd-disable)  ; Disable smart behavior
(smart-gd-goto-definition-or-references)  ; Manual invocation
```

## 🔧 How It Works Internally

1. **LSP Detection**: First tries to use LSP server to accurately determine if cursor is at definition
2. **Heuristic Fallback**: Falls back to pattern matching when LSP is unavailable
3. **Context Switch**: Calls `xref-find-references` if at definition, otherwise `xref-find-definitions`
4. **Universal Support**: Works with all LSP-supported languages (Go, Python, JavaScript, TypeScript, Rust, C/C++, etc.)

## 🛠️ Troubleshooting

If `gd` doesn't work as expected:

1. Enable debug mode: `(setq smart-gd-debug t)`
2. Check if advice is active: `(advice-mapc (lambda (advice _props) (message "%s" advice)) 'xref-find-definitions)`
3. Verify LSP is working: `C-h k gd` should show `xref-find-definitions`

## 📄 License

MIT License - see the source file for details.

## 🙏 Acknowledgments

Inspired by VSCode Vim plugin's intelligent navigation behavior. This brings that same productivity boost to Emacs users!
