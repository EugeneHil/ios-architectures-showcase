# iOS Architectures Showcase

One small app — a **todo list** — implemented in every mainstream iOS presentation
architecture, side by side. Built as a hands-on reference for interview preparation:
the goal is to *feel* the differences (boilerplate, data flow, testability, navigation)
rather than read about them.

Every sample implements the same feature set on top of the same `Shared` core,
so the only variable between them is the architecture itself.

## The sample app

Each architecture implements the same todo app:

- list of todos with done/pending state and priority
- search
- create / edit a todo (title, notes, priority)
- delete (swipe) and toggle done
- async storage with loading and error states — `InMemoryTodoRepository` simulates
  latency and can inject failures, so every pattern has to deal with async and errors

## Architectures

| # | Sample | UI | Status |
|---|--------|----|--------|
| 1 | [MVC](Architectures/MVC) | UIKit | ✅ done |
| 2 | [MVP](Architectures/MVP) | UIKit | ✅ done |
| 3 | [MVVM + Combine](Architectures/MVVMCombine) | UIKit | ✅ done |
| 4 | [MVVM + Coordinator](Architectures/MVVMCoordinator) | UIKit | ✅ done |
| 5 | [VIPER](Architectures/VIPER) | UIKit | ✅ done |
| 6 | [Clean Swift (VIP)](Architectures/CleanSwift) | UIKit | ✅ done |
| 7 | [MVI](Architectures/MVI) | SwiftUI | ✅ done |
| 8 | [TCA](Architectures/TCA) | SwiftUI | ✅ done |

## Cheat sheet (interview notes)

| Pattern | Data flow | Boilerplate | Testability | Navigation | Choose when |
|---|---|---|---|---|---|
| MVC | everything through the view controller | minimal | weak (logic glued to UIKit) | ad hoc, in the VC | tiny screens, prototypes |
| MVP | view ↔ presenter via protocols | medium | good (presenter is UIKit-free) | usually driven from the view | UIKit without reactive baggage |
| MVVM + Combine | bindable observable state | low | very good (view model tests) | still in the VC | the default modern UIKit choice |
| MVVM + Coordinator | same + extracted routing | medium | very good | coordinators own flows | medium/large UIKit apps |
| VIPER | six protocol-separated roles per module | high | excellent (presenter/interactor in isolation) | router per module | big teams, strict contracts |
| Clean Swift (VIP) | view → interactor → presenter cycle | high | very good | configurator + router | Clean Architecture, iOS-flavoured |
| MVI | single immutable state, one-way intents | medium (hand-rolled store) | excellent (pure reducer) | central, state-driven | predictable state, SwiftUI |
| TCA | composable reducers + effects | low (library-provided) | excellent (tested dependencies) | library navigation tools | production SwiftUI apps |

## Hands-on numbers

All samples implement the identical feature set against the same `Shared` core,
written in the same style — the only variable is the architecture:

| Sample | Swift files | Lines of code |
|--------|-------------|---------------|
| MVC | 3 | 391 |
| MVP | 7 | 584 |
| MVVM + Combine | 5 | 563 |
| MVVM + Coordinator | 8 | 629 |
| VIPER | 13 | 756 |
| Clean Swift (VIP) | 14 | 868 |
| MVI (hand-rolled) | 6 | 442 |
| TCA | 5 | 415 (+ the library itself) |

## Hands-on impressions (short)

- **MVC** — fastest to write, zero ceremony; every responsibility lives in one file, and it shows after ~300 lines.
- **MVP** — extracting the presenter is cheap; the two-way protocols and the render-what-changed dance in the form are the annoying part.
- **MVVM + Combine** — best effort/benefit for UIKit: bindings remove glue code, view models test trivially. Navigation inside the view controller is the weak spot.
- **MVVM + Coordinator** — coordinators fix exactly that weak spot, at the price of one more moving part per flow.
- **VIPER** — the interactor/presenter split feels right; the protocol mesh and module-I/O ceremony double the file count.
- **Clean Swift** — the same strictness as VIPER with worse ergonomics: every use case is a triple of Request/Response/ViewModel types.
- **MVI** — the smallest SwiftUI solution with a real architecture: one state struct, one reducer, glue bindings. Effects and testing infrastructure you build yourself.
- **TCA** — MVI with the missing 90% (effects, dependencies, testing, navigation) provided by the library; the shortest sample for how much it does.

## Repository layout

```
iOS-Architectures-Showcase/
├── README.md
├── Shared/            # Todo model, async repository, module plumbing — used by every sample
├── ShowcaseApp/       # thin app: architecture menu + UIKit bridge
└── Architectures/
    ├── MVC/           # one folder = one architecture = one namespace (`MVC.`)
    ├── MVP/
    ├── MVVMCombine/
    ├── MVVMCoordinator/
    ├── VIPER/
    ├── CleanSwift/
    ├── MVI/
    └── TCA/
```

There is a single app target: every sample's types live inside a caseless enum named
after its folder (`enum MVC`, `enum VIPER`, …), so identical file and type names across
samples never collide and cross-sample references are obvious in review.

## Creating the Xcode project (one time)

The `.xcodeproj` is created once in Xcode and then committed; there is no code
generation in this repo.

1. Xcode → **File → New → Project → iOS → App**
2. Product Name: `ArchitecturesShowcase`, Interface: **SwiftUI**, Language: Swift, Storage: None
3. Save **into the repository root** (`iOS-Architectures-Showcase/`); uncheck *Create Git repository*
4. In the project navigator delete the generated `ContentView.swift` and `ArchitecturesShowcaseApp.swift` (Move to Trash)
5. Drag the folders `Shared`, `ShowcaseApp` and `Architectures` from Finder into the
   `ArchitecturesShowcase` project group → choose **Create folder references** so that
   files added later are picked up automatically (on Xcode 15 or older choose
   *Create groups* and re-drag new folders) → make sure the target
   **ArchitecturesShowcase** is checked
6. Run ▶ — you get the architecture menu; each row opens the same todo app built with that pattern

All samples except TCA build out of the box. **TCA requires one extra step** — add the
library via **File → Add Package Dependencies** →
`https://github.com/pointfreeco/swift-composable-architecture` — the app target does not
build until this dependency is added.

## Roadmap

- [x] MVC (UIKit)
- [x] MVP (UIKit)
- [x] MVVM + Combine (UIKit)
- [x] MVVM + Coordinator (UIKit)
- [x] VIPER (UIKit)
- [x] Clean Swift / VIP (UIKit)
- [x] MVI — hand-rolled unidirectional store (SwiftUI)
- [x] TCA (SwiftUI)
- [x] Final comparison pass: fill this README with hands-on impressions
