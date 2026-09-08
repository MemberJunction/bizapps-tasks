/** @type {import('@memberjunction/config').MJConfig} */
module.exports = {
  entityPackageName: '@mj-biz-apps/tasks-entities',

  testing: {
    checkModules: ['@mj-biz-apps/tasks-integration-tests'],
  },

  output: [
    { type: 'SQL', directory: './SQL Scripts/generated', appendOutputCode: true },
    { type: 'EntitySubclasses', directory: './packages/Entities/src/generated' },
    { type: 'ActionSubclasses', directory: './packages/Actions/src/generated' },
    { type: 'GraphQLServer', directory: './packages/Server/src/generated' },
    {
      type: 'Angular',
      directory: './packages/Angular/src/lib/generated',
      options: [{ name: 'maxComponentsPerModule', value: 20 }],
    },
    { type: 'DBSchemaJSON', directory: './Schema Files' },
  ],

  commands: [
    {
      workingDirectory: './packages/Entities',
      command: 'npm',
      args: ['run', 'build'],
      when: 'after',
    },
    {
      workingDirectory: './packages/Actions',
      command: 'npm',
      args: ['run', 'build'],
      when: 'after',
    },
  ],

  // Allow-list: CodeGen this app's schema only (MJ >= 5.50 includeSchemas).
  // Unnamed schemas — core, siblings, never-seen client schemas — are excluded.
  includeSchemas: ['__mj_BizAppsTasks'],
  excludeSchemas: [],
  /**
   * Schema → npm for peer entity classes this emit does NOT generate
   * (embeds + related-record collections). Distinct from:
   *   includeSchemas     — what this run generates
   *   entityPackageName  — the npm package this run writes (string form)
   * Core (__mj) always comes from @memberjunction/core-entities; do not list it.
   * Do not map a foreign schema to this emit's own package.
   */
  entityImportPackages: {
    '__mj_BizAppsCommon': '@mj-biz-apps/common-entities',
  },

  // SQL output configuration with Flyway placeholders.
  // The app's own schema (__mj_BizAppsTasks) maps to ${flyway:defaultSchema} so it is
  // resolved at migrate time; core MJ uses the named ${mjSchema} placeholder.
  // __mj_BizAppsCommon is left literal (matches the bizapps-accounting convention).
  SQLOutput: {
    enabled: true,
    folderPath: './migrations/codegen/',
    appendToFile: false,
    convertCoreSchemaToFlywayMigrationFile: true,
    omitRecurringScriptsFromLog: false,
    schemaPlaceholders: [
      // Order matters: more-specific schemas must come first because
      // substitution is run sequentially with a greedy regex. If '__mj'
      // were listed first, it would also match the '__mj' prefix of
      // '__mj_BizAppsTasks', producing '${mjSchema}_BizAppsTasks'.
      { schema: '__mj_BizAppsTasks', placeholder: '${flyway:defaultSchema}' },
      { schema: '__mj', placeholder: '${mjSchema}' }
    ]
  },

  newEntityDefaults: {
    NameRulesBySchema: [
      { SchemaName: '${mj_core_schema}', EntityNamePrefix: 'MJ: ' },
      {
        SchemaName: '__mj_BizAppsTasks',
        EntityNamePrefix: 'MJ_BizApps_Tasks: ',
        EntityNameSuffix: '',
      }
    ]
  },

  dbHost: process.env.DB_HOST ?? 'localhost',
  dbPort: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 1433,
  dbDatabase: process.env.DB_DATABASE,
  dbUsername: process.env.DB_USERNAME,
  dbPassword: process.env.DB_PASSWORD,
  codeGenLogin: process.env.CODEGEN_DB_USERNAME,
  codeGenPassword: process.env.CODEGEN_DB_PASSWORD,
};
