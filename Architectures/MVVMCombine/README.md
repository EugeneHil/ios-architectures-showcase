# MVVM + Combine

**Status:** ✅ implemented

The view model exposes observable state and intent methods; the view controller binds
inputs and outputs with Combine and stays free of presentation logic.

## Structure

- `MVVMCombineModule.swift` — namespace, metadata, module entry
- `TodoList/TodoListViewModel.swift` — `@MainActor`; `state`/`events`/`errors` as subjects, intents as methods
- `TodoList/TodoListViewController.swift` — binds via `cancellables`; diffable table; swipes and taps forward intents
- `AddEditTodo/AddEditTodoViewModel.swift` — pure form state + validation, emits the finished `Todo`
- `AddEditTodo/AddEditTodoViewController.swift` — form UI; one binding (`isSaveEnabled`)

## Design decisions to notice

- **Contract style**: inputs are plain methods, outputs are `CurrentValueSubject`/`PassthroughSubject` — readable and easy to mock
- **`@MainActor` view model**: subscribers always receive values on the main thread — no `receive(on:)` noise
- **Formatting lives in the view model**: `TodoRow` (title/subtitle/isDone) and `emptyMessage` are ready to render — the VC never builds display strings
- **Navigation stays in the VC** (via the `events` publisher) — plain MVVM's honest weak spot; the Coordinator sample exists to fix exactly this
- **Persistence ownership**: the form VM only validates and emits a `Todo`; `TodoListViewModel` persists it — one owner for the list's data flow
- **Testability**: view models import no UIKit — they can be exercised with just a mocked repository (a favourite interview question about MVVM)
