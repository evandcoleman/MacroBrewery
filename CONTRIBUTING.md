# Contributing to MacroBrewery

Thank you for your interest in contributing to MacroBrewery!

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/MacroBrewery.git`
3. Create a branch: `git checkout -b feature/your-feature`

## Development

### Building

```bash
swift build
```

### Testing

```bash
swift test
```

### Running the Example Client

```bash
swift run MacroBreweryClient
```

## Adding a New Macro

1. Create the macro implementation in `Sources/MacroBreweryMacros/Macros/`
2. Register it in `Sources/MacroBreweryMacros/MacroBreweryMacro.swift`
3. Add the public declaration in `Sources/MacroBrewery/MacroBrewery.swift`
4. Add tests in `Tests/MacroBreweryTests/`
5. Add an example to `Sources/MacroBreweryClient/main.swift`

## Pull Request Guidelines

- Follow existing code style
- Add tests for new functionality
- Update documentation as needed
- Keep PRs focused on a single change

## Reporting Issues

When reporting bugs, please include:
- Swift version (`swift --version`)
- macOS version
- Steps to reproduce
- Expected vs actual behavior
