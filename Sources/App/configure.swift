import FluentPostgreSQL
import Vapor
import Leaf
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(LeafProvider())
    try services.register(AuthenticationProvider())

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a database
    var databases = DatabasesConfig()
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "futurDBuser"
    
    //app testing
    let databaseName: String
    let databasePort: Int
    if (env == .testing) {
        databaseName = "vapor-test"
        if let testPort = Environment.get("DATABASE_PORT") {
            databasePort = Int(testPort) ?? 5433
        } else {
            databasePort = 5433
        }
    } else {
        databaseName = Environment.get("DATABASE_DB") ?? "futurdbtest"
        databasePort = 5432
    }
    
    let password = Environment.get("DATABASE_PASSWORD") ?? "futurDBpassword"
    
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        port: databasePort,
        username: username,
        database: databaseName,
        password: password
    )
    
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
    
    
    /// Configure migrations
    var migrations = MigrationConfig()
    //add the user model
    migrations.add(model: User.self, database: .psql)
    //add the post model
    migrations.add(model: Post.self, database: .psql)
    //add the token model
    migrations.add(model: Token.self, database: .psql)
    services.register(migrations)
    
    // 1
    var commandConfig = CommandConfig.default()
    // 2
    commandConfig.useFluentCommands()
    // 3
    services.register(commandConfig)
    
    //prefer leaf
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    //User.Public
    User.Public.defaultDatabase = .psql
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
}
