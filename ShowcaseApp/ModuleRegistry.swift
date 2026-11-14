/// All architecture samples in recommended reading order.
enum ModuleRegistry {
    static let modules: [any ArchitectureModule.Type] = [
        MVC.self,
        MVP.self,
        MVVMCombine.self,
        MVVMCoordinator.self,
        VIPER.self,
        CleanSwift.self,
        MVI.self,
        TCA.self,
    ]
}
